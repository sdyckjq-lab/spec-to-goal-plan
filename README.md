# Spec To Goal Plan

[简体中文](./README.md) | [English](./README.en.md)

Spec To Goal Plan 是一个本地 Codex/agent Skill，用来把已经完成的规格说明或设计文档，转换成尺寸合适、可以直接执行的计划。

它适合用在方向已经确定、但还没有开始实现的时候。这个 Skill 会检查规格是否足够可执行，判断任务大小，小任务会生成扁平清单而不是完整阶段计划；同时它会梳理实现范围、定义明确的验收标准和提交规则，最后生成一段可以直接复制使用的 `/goal` 启动提示。

## 产出内容

- 规格可执行性检查
- 任务规模判断（S / M / L），并给出一句话原因
- 实现范围地图
- 分阶段执行计划、扁平清单，或批处理 JSON 台账
- 进度文件，以及只允许翻转状态的更新规则
- 明确的验收标准和验证计划
- 用于自主执行的 Git 分支和提交规则
- 可以直接复制使用的 `/goal` 启动提示

## Requirements

- Codex CLI >= 0.133（从该版本开始，goal mode 默认启用）。
- `/goal` 只在已保存的会话中可用；临时会话不能保存 goal。
- Plan mode 会暂停 goal 继续执行；运行台账时请使用普通模式。
- goal 目标最多 4,000 个字符；生成的启动提示会指向计划文件，而不是把完整计划嵌进去。

## 仓库结构

```text
.
├── SKILL.md                      # 主要 Skill 说明和触发元数据
├── agents/
│   └── openai.yaml               # Codex 界面元数据（显示名称、默认提示）
├── references/
│   ├── phased-plan.md            # L 级任务手册：阶段、验收、progress.json
│   └── checklist-ledger.md       # M 级任务的扁平清单和批处理台账
├── evals/
│   └── evals.json                # 代表性的触发、路由和非触发用例
└── scripts/
    └── validate.sh               # 本地格式检查
```

## 本地安装

把这个仓库复制或链接到你的本地 skills 目录。

```bash
mkdir -p ~/.agents/skills
ln -s "$(pwd)" ~/.agents/skills/spec-to-goal-plan
```

如果已经有同名 Skill，请先删除或重命名旧版本。

## 使用示例

```text
基于 docs/spark/editor-design.md，写一个独立 phased plan 和 progress.json，后面我要用 /goal 跑。
```

```text
把这个 spec review 一遍，看看能不能变成 goal 执行计划。先给方案，别直接写。
```

```text
我要逆向这个代码库，先用脚本整理完整 list 成 json，然后按 /goal 分批处理，每批处理完更新 json。
```

## 不适合的场景

这个 Skill 不适合用来头脑风暴、撰写原始规格、生成普通任务列表、做代码审查，或执行已经存在的计划。对于非常小的改动，它会建议直接执行，而不是生成计划。

## 验证改动

提交更新前请运行：

```bash
./scripts/validate.sh
```

验证会检查 Skill 头部信息（包括长度限制）、agent 元数据层级、参考文件和 eval JSON。

## 维护说明

- 以 `SKILL.md` 作为行为说明的唯一真实来源；台账模板放在 `references/`。
- 触发或路由行为变化时，同步更新 `evals/evals.json`。
- 保持使用示例和触发说明一致。
- 优先使用清晰、长期有效的说明，避免依赖上下文的表达。

## 许可证

MIT
