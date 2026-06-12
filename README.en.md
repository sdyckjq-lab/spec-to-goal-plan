# Spec To Goal Plan

[简体中文](./README.md) | English

Spec To Goal Plan is a local Codex/agent Skill that turns a finished spec or design document into a right-sized execution plan.

It is meant for the moment after the direction is already decided, but before implementation starts. The Skill reviews whether the spec is executable, sizes the task (small tasks get a flat checklist instead of full phases), maps the implementation surface, defines hard acceptance criteria and commit rules, and ends with a copy-ready `/goal` starter prompt.

## What This Skill Produces

- Spec readiness review
- Task sizing (S / M / L) with a one-line reason
- Implementation surface map
- Phased execution plan, flat checklist, or batch JSON ledger
- Progress file with status-flip-only update rules
- Hard acceptance criteria and verification plan
- Git branch and commit rules for autonomous execution
- Copy-ready `/goal` starter prompt

## Requirements

- Codex CLI >= 0.133 (goal mode enabled by default since that release).
- `/goal` only works in saved sessions; ephemeral sessions cannot hold goals.
- Plan mode suspends goal continuation; run the ledger in normal mode.
- A goal objective is limited to 4,000 characters; the generated starter points at the plan file instead of embedding it.

## Repository Layout

```text
.
├── SKILL.md                      # Main Skill instructions and trigger metadata
├── agents/
│   └── openai.yaml               # Codex interface metadata (display name, default prompt)
├── references/
│   ├── phased-plan.md            # L-level playbook: phases, acceptance, progress.json
│   └── checklist-ledger.md       # M-level flat checklist and batch inventory ledger
├── evals/
│   └── evals.json                # Representative trigger, routing, and non-trigger cases
└── scripts/
    └── validate.sh               # Local format checks
```

## Install Locally

Copy or link this repository into your local skills directory.

```bash
mkdir -p ~/.agents/skills
ln -s "$(pwd)" ~/.agents/skills/spec-to-goal-plan
```

If a Skill with the same name already exists, remove or rename the old copy first.

## Usage Examples

```text
基于 docs/spark/editor-design.md，写一个独立 phased plan 和 progress.json，后面我要用 /goal 跑。
```

```text
把这个 spec review 一遍，看看能不能变成 goal 执行计划。先给方案，别直接写。
```

```text
我要逆向这个代码库，先用脚本整理完整 list 成 json，然后按 /goal 分批处理，每批处理完更新 json。
```

## When Not To Use It

This Skill is not for brainstorming, writing the original spec, ordinary task lists, code review, or executing an existing plan. For very small changes it will recommend direct execution instead of generating a plan.

## Validate Changes

Run this before committing updates:

```bash
./scripts/validate.sh
```

The validation checks the Skill frontmatter (including length limits), agent metadata nesting, reference files, and eval JSON.

## Maintenance Notes

- Keep `SKILL.md` as the source of truth for behavior; ledger templates live in `references/`.
- Update `evals/evals.json` whenever trigger or routing behavior changes.
- Keep usage examples aligned with the trigger description.
- Prefer clear, durable instructions over context-dependent phrasing.

## License

MIT
