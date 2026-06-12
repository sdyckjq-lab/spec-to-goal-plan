# Changelog

## 0.2.0 - 2026-06-12

- Fix `agents/openai.yaml`: nest fields under `interface:` so Codex actually reads them; mention `$spec-to-goal-plan` in the default prompt.
- Shorten the frontmatter description and front-load trigger words to survive metadata budget truncation.
- Add S/M/L task sizing: small tasks get a direct-execution recommendation, medium tasks get a flat checklist, large tasks get the full phased plan.
- Add git rules for autonomous execution: dedicated branch with clean-start commit, commit per verified work unit, never push/merge/amend, no auto-commit for small tasks.
- Trim the `/goal` starter to the ledger protocol only; the official goal continuation prompt already enforces completion auditing and goal fidelity.
- Constrain progress file updates to status/evidence/log fields and add an opening smoke-check step to the `/goal` starter.
- Split ledger templates into `references/phased-plan.md` and `references/checklist-ledger.md`, loaded based on the sizing route.
- Document `/goal` prerequisites (Codex >= 0.133, saved sessions, 4,000-character objective limit).
- Extend `evals/evals.json` with routing cases and strengthen `scripts/validate.sh` (length limits, interface nesting, reference files).

## 0.1.0 - 2026-06-12

- Publish the initial open-source repository shape.
- Include the main `spec-to-goal-plan` Skill instructions.
- Include OpenAI agent metadata.
- Include representative eval cases.
- Add local validation script.
