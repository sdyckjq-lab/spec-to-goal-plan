# Spec To Goal Plan

Spec To Goal Plan is a local Codex/agent Skill that turns a finished spec or design document into an engineering-quality execution plan.

It is meant for the moment after the direction is already decided, but before implementation starts. The Skill reviews whether the spec is executable, maps the implementation surface, creates a phased plan or checklist ledger, defines hard acceptance criteria, and ends with a copy-ready `/goal` starter prompt.

## What This Skill Produces

- Spec readiness review
- Implementation surface map
- Engineering review additions
- Phased execution plan or checklist/JSON ledger
- Progress file shape for long-running `/goal` work
- Hard acceptance criteria
- Verification and eval plan
- Decision log and drift guard
- Copy-ready `/goal` starter prompt

## Repository Layout

```text
.
├── SKILL.md              # Main Skill instructions and trigger metadata
├── agents/
│   └── openai.yaml       # Display metadata and default prompt
├── evals/
│   └── evals.json        # Representative trigger and non-trigger cases
└── scripts/
    └── validate.sh       # Local format checks
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

This Skill is not for brainstorming, writing the original spec, ordinary task lists, code review, or executing an existing plan. It is specifically for converting a finished spec/design into a durable `/goal` execution plan.

## Validate Changes

Run this before committing updates:

```bash
./scripts/validate.sh
```

The validation checks the Skill frontmatter, agent metadata, and eval JSON.

## Maintenance Notes

- Keep `SKILL.md` as the source of truth for behavior.
- Update `evals/evals.json` whenever trigger behavior changes.
- Keep usage examples aligned with the trigger description.
- Prefer clear, durable instructions over context-dependent phrasing.

## License

MIT
