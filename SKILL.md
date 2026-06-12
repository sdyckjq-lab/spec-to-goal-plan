---
name: spec-to-goal-plan
description: Convert a finished spec or design document into an engineering-quality plan, goal-ready execution ledger, and /goal starter prompt. Use this skill whenever the user says they have finished a spec/design and wants to turn it into phases, a phased plan, a progress/checklist JSON file, hard acceptance criteria, batch processing lists, implementation mapping, test plan, decision log, or a /goal starter prompt. Trigger for requests like "基于这个 spec 写 /goal plan", "把这个设计文档拆成可执行 phase", "写完 spec 了，生成 /goal", "把 spec 变成 phased plan 和 progress 文件", "把逆向代码的完整 list 做成 checklist/json 分批处理", or "按 goal 流程把设计落成计划". This skill treats /goal as one persistent-objective mechanism and designs the external ledger it should follow; do not use for initial brainstorming, writing the original spec, or implementing the plan.
---

# Spec To Goal Plan

Use this skill after a spec/design is already written and the user wants to make it executable through Codex `/goal`.

Your job is not to implement the work. Your job is to turn a confirmed direction into an engineering-quality plan and external execution ledger that can survive long execution, context compaction, handoffs, and auditable phase or batch execution.

## Core Position

This skill sits between spec and execution:

```text
brainstorm / direction
-> spec or design document
-> this skill: spec review + implementation mapping + engineering plan + execution ledger + /goal starter
-> /goal execution
```

Important: `/goal` is one persistent-objective mechanism, not a checklist engine and not a phase engine. It stores the objective and keeps nudging Codex to continue. The checklist, JSON ledger, phased plan, and progress file are external execution ledgers that make the objective auditable and resumable.

If the user is still deciding product direction, do not write the execution plan yet. Help identify the missing decisions and ask for confirmation.

## Required Inputs

Look for these before drafting:

- The spec/design document path, pasted spec, or clearly selected text.
- The intended scope: product area, repo area, or document family.
- Any source-of-truth docs that must be respected.
- Whether the output should be written to files or only proposed in chat.

If the user did not provide a spec/design document, ask for it. This skill is not for free-form task planning from a vague idea.

## Workflow

### 1. Read And Anchor

Read the provided spec/design and any source-of-truth docs it references. If working in a repo, also read local project rules such as `AGENTS.md`, `CLAUDE.md`, or equivalent files when present.

Track the newest direction explicitly. Long-running plans drift when older wording survives in the plan, so treat the latest user-confirmed direction as the source of truth.

### 2. Spec Review Gate

Before writing a plan, review whether the spec is executable.

Return a short review with:

- **Ready:** yes/no.
- **Blocking gaps:** decisions missing, contradictions, stale wording, unclear scope, vague acceptance.
- **Drift risks:** places where older language could pull execution away from the latest direction.
- **Required fixes:** what must change before plan writing.

If there are blocking gaps, stop and ask for the specific decision. Do not invent a phase plan that hides uncertainty.

### 3. Map Implementation Surface

Before writing phases, map the work to concrete implementation surfaces. This borrows the useful part of implementation-plan skills: make the plan specific enough that a fresh worker can execute it without guessing.

Include only surfaces that are relevant to the spec:

- Existing files, modules, routes, pages, agents, skills, prompts, tools, data models, APIs, tests, docs, or scripts likely to change.
- New files or artifacts that should be created.
- Existing capabilities that should be reused instead of rebuilt.
- Interfaces and boundaries: what each component owns, what it receives, what it returns, and what it must not know.
- Data flow or state flow for any non-trivial workflow.
- Integration points with external services, local tools, browser flows, evals, or knowledge stores.

If the repo is available, inspect enough code to avoid making up file paths, framework names, test commands, or module boundaries. If exact paths cannot be known yet, say so and make the next discovery action explicit in the first phase.

For non-trivial flows, include an ASCII diagram in the plan. Prefer simple diagrams that explain ownership and direction:

```text
User action
  -> UI / command entry
  -> orchestration layer
  -> domain service
  -> persistence / external tool
  -> verification / user-visible result
```

### 4. Built-In Engineering Review

The plan should include the useful review checks before execution begins. Do not turn this into a separate interactive review gauntlet. Auto-resolve ordinary planning decisions using the decision principles below, record meaningful tradeoffs, and only stop for a user decision when the plan would change the user's stated direction.

Review these dimensions while drafting:

- **Architecture:** component boundaries, coupling, data flow, state transitions, security boundaries, scaling or single-point failure risks.
- **Reuse:** what already exists, whether the plan reuses it, and where rebuilding would be wasteful.
- **Code quality:** DRY risks, over-clever abstractions, naming consistency, error handling, and places where a smaller focused file/module is better.
- **Tests:** every new user flow, code path, edge state, error path, and LLM/prompt change needs a matching automated test, browser check, or eval where practical.
- **Failure modes:** for each critical path, name one realistic way it can fail and whether the user sees a clear recovery path or a silent failure.
- **Performance:** obvious N+1/data loading issues, slow browser flows, memory growth, repeated LLM/tool calls, or avoidable work.
- **Operations:** migrations, deployment, generated artifacts, compatibility, rollback, and how the change is verified after shipping when relevant.

For LLM, prompt, agent, or Skill changes, include eval requirements when the project has evals or the behavior is important enough to test with representative cases.

### 5. Decision Principles

Use these principles to make ordinary plan-writing decisions without repeatedly asking the user:

1. **Complete beats shortcut:** prefer the plan that covers real edge cases, not only the demo path.
2. **Reuse existing capability:** if the repo already has a pattern, helper, Skill, agent, parser, or service for the job, plan to reuse it.
3. **Explicit beats clever:** choose the approach a new contributor can understand quickly.
4. **Small focused work blocks:** split by independently verifiable outcomes, not by microscopic operations.
5. **Test the behavior that can break:** user flows, error states, edge cases, and LLM outputs matter as much as pure code branches.
6. **Record meaningful tradeoffs:** decisions should live in the plan/progress files, not only in chat.
7. **Challenge only real direction changes:** if a recommendation would remove, merge, split, or substantially change what the user asked for, surface it as an open decision before writing the final plan.

Do not copy verbose interactive question formats from other skills. This skill is meant to produce a plan that can execute cleanly, not trap the user in review loops.

### 6. Design The Execution Ledger

Design the ledger that `/goal` should follow. Do not describe these as separate `/goal` modes. They are different ledger shapes for the same persistent goal mechanism.

**Checklist / JSON ledger shape**

Use this when the work is enumerable and repetitive, such as reverse engineering code, processing many files, extracting APIs, auditing routes, migrating many similar items, or checking a complete inventory.

Require a script or structured parser to build the full item list when possible. Do not ask the agent to hand-maintain a huge list from memory.

This ledger should contain:

- A checklist or JSON ledger containing the complete item list.
- A batching rule such as "process 20 items per turn" or "one subsystem per batch".
- Per-item fields for status, notes, evidence, verification, and commit if relevant.
- A rule that every turn reads the ledger first, processes only the next batch, updates the ledger, verifies, and commits if the work changed files.
- A resume rule: after compaction or handoff, trust the ledger over chat memory.

Minimal JSON shape:

```json
{
  "goal": "Reverse engineer the target subsystem",
  "source": "script/generated-inventory.json",
  "batching": {
    "batch_size": 20,
    "current_batch": 1
  },
  "items": [
    {
      "id": "route.users.create",
      "status": "pending",
      "evidence": [],
      "notes": "",
      "verification": [],
      "commit": null
    }
  ]
}
```

**Phased plan ledger shape**

Use this when a design/spec describes a product or engineering change that should land in stages. This is the default for feature work, UI redesigns, architecture changes, knowledge workflows, or anything requiring phase-level acceptance.

This ledger should contain:

- A phased plan.
- A progress file.
- Hard acceptance criteria for every phase.
- A rule that each completed task is verified and committed.
- A rule that phase completion is verified, recorded in the progress file, and then advances automatically to the next phase without asking the user for approval.
- A rule that phase transitions may be summarized, but must not pause for user confirmation unless a real blocker changes the user's stated direction.

If both shapes apply, combine them: use a phased plan as the outer ledger and attach a checklist/JSON ledger inside any phase that has a large enumerable inventory.

### 7. Task Granularity

Do not split work into tiny operation steps. Split it into verifiable work blocks.

Use this rule:

```text
Phase = a user-visible or system-visible delivery stage.
Work Unit = a chunk that is worth verifying and committing.
Checklist Item = a tracked inventory item inside a batch, not necessarily one turn.
```

Avoid microscopic task lists like:

```text
read file A
edit file A
run test
commit
```

Prefer tasks like:

```text
Implement the entry flow UI and routing.
Wire the entry flow to persistence.
Verify the entry flow with browser coverage.
```

Default sizing:

- A normal feature should have 3-5 phases.
- A large refactor should have 5-7 phases.
- Each phase should usually contain 2-5 work units.
- One `/goal` turn should complete one work unit or one checklist batch when possible.
- Checklist batches should usually process 10-20 items, not one item per turn.
- More than 8 phases, more than 6 work units in one phase, or one-item batches require a short justification.
- Do not require every work unit to contain full code snippets. Include exact code only when it removes ambiguity and is stable enough to be useful.

### 8. Phase Breakdown

When the spec is ready, split it into phases by independently verifiable work surfaces, not by document sections.

Each phase needs:

- A clear phase goal.
- The user-visible or system-visible result.
- Implementation surfaces: files/modules/routes/tools/docs/tests likely touched.
- In-scope tasks.
- Out-of-scope boundaries.
- Hard acceptance conditions.
- Required verification.
- Automatic advancement rule before the next phase.
- Commit boundary.

Prefer 3-8 phases for large work. If there are more than 8, explain why or group them.

### 9. Hard Acceptance

Acceptance must be binary. Replace vague wording:

```text
Weak: 页面体验正常。
Hard: Browser check at 390px, 768px, and 1440px shows no horizontal scroll; the primary flow completes; key controls are clickable.

Weak: 测试通过。
Hard: `npm run test:server` and `npm run test:web` exit 0 and the result is recorded in progress.json.

Weak: 文档已更新。
Hard: design.md, plan.md, and progress.json agree on phase goals, boundaries, and acceptance; no stale wording conflicts with latest direction.
```

For code work, every phase should have at least one automated check unless the repo has no runnable test surface. For UI work, include browser verification. For document-only work, include file assertions and conflict review.

### 10. Test And Verification Plan

Every plan needs a verification section that is strong enough to drive implementation.

Include:

- Detected or expected test commands. Prefer commands from project docs; otherwise infer from repo files.
- Unit/integration/E2E/browser/eval checks, matched to the behavior they prove.
- Edge cases and error paths that must be covered.
- For UI work, viewport/browser coverage and critical click paths.
- For LLM/prompt/agent changes, representative eval cases or manual transcript checks if no eval harness exists.
- For document-only work, conflict review against source docs and latest direction.

If no runnable test framework exists, say that directly and make the acceptance rely on available checks, file assertions, browser checks, or review artifacts. Do not write "tests pass" without naming what can actually run.

### 11. Failure Modes And Scope Boundaries

The plan should include:

- **What already exists:** existing files, flows, agents, Skills, docs, or services that solve part of the problem.
- **Not in scope:** work deliberately deferred, with one-line rationale.
- **Failure modes:** realistic ways the new behavior can break and how the plan catches or handles them.
- **Residual risk:** what remains uncertain after the planned verification.

If a failure mode would be silent to the user and has no planned test or handling, treat it as a plan gap and fix the plan before marking it ready.

### 12. Decision Log

For important choices, include a short decision log in the plan. This keeps `/goal` execution stable after context compaction.

Record:

- Decision.
- Reason.
- Alternatives rejected.
- Source: spec, code inspection, project rule, or latest user direction.

Example:

```markdown
## Decision Log

| Decision | Reason | Rejected | Source |
|---|---|---|---|
| Use a combined phased plan plus checklist JSON | The work has product phases and a large route inventory | Pure markdown checklist | Spec + code inventory |
```

Do not over-log tiny choices. Log choices that affect architecture, scope, tests, data flow, UX flow, or future execution.

### 13. Execution Plan Or Ledger Document

Create or propose one execution plan or ledger document. For design/spec implementation, this is usually a phased plan. For enumerable reverse-engineering or batch-processing work, this can be a checklist/JSON ledger with batching rules. Do not split one feature into many separate plan documents unless the user explicitly asks.

The plan or ledger should include:

- Goal.
- Source documents.
- Execution rules.
- `/goal` execution protocol.
- Progress file path.
- Execution ledger shape: phased plan, checklist/JSON ledger, or combined.
- Implementation surface map.
- Architecture/data-flow diagram when useful.
- Phase list.
- Per-phase tasks.
- Per-phase acceptance.
- Per-phase implementation surfaces.
- Checklist or inventory generation rule when the work is enumerable.
- Verification commands.
- Test and eval plan.
- What already exists.
- Not in scope.
- Failure modes and residual risk.
- Decision log.
- Drift guard checklist.
- Commit rules.
- Final review and ship rules.

Use repo-local naming conventions when available. If none exist, use:

```text
docs/plans/<date>-<topic>-phased-plan.md
docs/plans/<date>-<topic>-progress.json
```

For checklist-ledger work, use names like:

```text
docs/plans/<date>-<topic>-execution-ledger.md
docs/plans/<date>-<topic>-checklist.json
```

If the repo already uses a different plan directory, follow the repo.

### 14. Progress File

Create or propose a progress file that can answer:

```text
- Which phase and task is current?
- What is the next allowed action?
- Which tasks are done, pending, or blocked?
- Which commit proves each done task?
- Which verification commands passed?
- Which drift guard answers were checked?
- Which decision log entries or source directions affected this turn?
- What residual risk remains?
```

Minimal shape:

```json
{
  "plan": "docs/plans/<topic>-phased-plan.md",
  "status": {
    "phase": "phase-1",
    "task": "1.0",
    "next_allowed_action": "Implement the current task; after verified completion, update progress to the next task or next phase automatically"
  },
  "execution_rules": {
    "commit_each_completed_task": true,
    "advance_after_verified_phase": true,
    "no_user_confirmation_between_phases": true,
    "no_commit_on_failed_verification": true
  },
  "decision_log": [],
  "phases": [],
  "turn_log": []
}
```

For checklist-only or document-only work, a markdown checklist is acceptable if it records current task, verification, and completion status clearly. For large inventories, prefer JSON because it is easier to update and inspect mechanically.

### 15. Plan Self-Review

After writing the complete plan, review it against the source spec and project context before reporting it ready.

Check:

- Every spec requirement maps to at least one phase, work unit, checklist item, or explicit out-of-scope entry.
- No stale wording conflicts with the latest direction.
- No placeholder language remains: `TBD`, `TODO`, `later`, `handle edge cases`, `add tests`, `similar to`, or vague equivalents.
- File paths, commands, phase names, data names, and test names are consistent.
- Acceptance conditions are binary and verifiable.
- Verification commands are realistic for the repo.
- Existing capabilities are reused where appropriate.
- Failure modes and residual risks are recorded.
- The plan explicitly forbids user confirmation pauses between phases; verified phases advance automatically.

Fix issues inline before presenting the result. If the plan would require changing the user's stated direction, stop and ask for that decision instead of silently changing it.

### 16. /goal Starter

End with a copy-ready `/goal` starter prompt. Keep it under the CLI goal length limit by pointing to the plan and progress file instead of embedding the whole plan.

Template:

```text
/goal Implement <plan-or-ledger-path> by following its execution ledger.

Before every turn:
1. Read <progress-path>.
2. Read the current phase/task or checklist batch in <plan-or-ledger-path>.
3. Re-read the source design docs listed in the plan.
4. Read the implementation map, verification plan, failure modes, and decision log sections that apply to the current work.
5. Check git status and preserve unrelated user changes.
6. State the current phase/task and exact acceptance checks for this turn.

Work rules:
- Work only on the current work unit unless <progress-path> explicitly advances.
- If the plan includes a checklist/json ledger, process only the next batch and update the ledger before ending the turn.
- After every completed task, verify it, update <progress-path>, commit that task, then record the real commit hash.
- Advance into the next phase after the current phase acceptance conditions are verified and recorded.
- Do not ask the user for phase-boundary approval. Summarize the completed phase and continue automatically.
- If implementation discovers a conflict with the plan, update the plan/progress files or stop when it would change the user's stated direction.
- Do not commit if required verification fails.

Done when:
1. All phases, batches, or checklist items in <plan-or-ledger-path> are complete.
2. Every acceptance condition is proven.
3. <progress-path> records final status, verification, commit hashes, drift review, and residual risk.

Stop if:
- The plan conflicts with the latest design direction.
- Required verification fails after three serious attempts.
- A product decision is missing.
- The worktree contains unrelated changes that cannot be safely separated.
```

## Output Format

When the user asks for a proposal first, respond in chat with:

```text
Spec Review
Implementation Map
Engineering Review Additions
Execution Ledger
Phase Breakdown
Plan Files
/goal Starter
Open Questions
```

When the user asks you to write files, create:

```text
<plan-or-ledger-path>
<progress-path>
```

Then report:

```text
Created
Reviewed
Ready to start /goal
```

Keep the final report concise and say whether the plan is ready to execute.

## Guardrails

- Do not write implementation code.
- Do not start `/goal` automatically.
- Do not compress unclear decisions into vague acceptance criteria.
- Do not downgrade the spec into MVP unless the user explicitly asks.
- Do not copy microscopic 2-5 minute implementation-step templates unless the user explicitly asks for that granularity.
- Do not import verbose interactive review gates. Do not ask for phase-boundary confirmation. Only ask when the spec is blocked or the plan would change the user's stated direction.
- Do not rely on chat memory alone; write stable files for long work.
- Do not hand-maintain large inventories if a script or structured parser can generate them.
- Do not expose this as a Superpowers dependency. It is a general spec-to-goal workflow.
- Preserve unrelated user changes if editing inside a repo.

## Good Trigger Examples

```text
写完这个 design 了，帮我拆 phase，然后生成 /goal 可以执行的 plan。
```

```text
基于 docs/spark/xxx-design.md，写一个独立 phased plan 和 progress.json，后面我要用 /goal 跑。
```

```text
我要逆向这个代码库，先用脚本整理完整 list 成 json，然后按 /goal 分批处理，每批处理完更新 json。
```

```text
把这个 spec review 一遍，看看能不能变成 goal 执行计划。先给方案，别直接写。
```

## Non-Triggers

Do not use this skill for:

- "帮我脑暴这个产品方向"
- "先写一个 spec"
- "按照 plan 开始实现"
- "review 这段代码"
- "帮我写普通 todo list"

Those tasks belong to brainstorming, spec writing, implementation, or review workflows.
