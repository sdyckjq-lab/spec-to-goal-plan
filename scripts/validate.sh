#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ruby -e '
  require "yaml"

  path = ARGV.fetch(0)
  text = File.read(path)
  abort "SKILL.md must start with YAML frontmatter" unless text.start_with?("---\n")

  parts = text.split("---\n", 3)
  abort "SKILL.md frontmatter is incomplete" unless parts.length == 3

  metadata = YAML.safe_load(parts[1])
  abort "SKILL.md frontmatter is missing name" unless metadata["name"]
  abort "SKILL.md frontmatter is missing description" unless metadata["description"]
  abort "Unexpected Skill name: #{metadata["name"]}" unless metadata["name"] == "spec-to-goal-plan"
  abort "SKILL.md body is empty" if parts[2].strip.empty?
' "$ROOT/SKILL.md"

ruby -e '
  require "yaml"

  metadata = YAML.safe_load(File.read(ARGV.fetch(0)))
  abort "agents/openai.yaml is missing display_name" unless metadata["display_name"]
  abort "agents/openai.yaml is missing short_description" unless metadata["short_description"]
  abort "agents/openai.yaml is missing default_prompt" unless metadata["default_prompt"]
' "$ROOT/agents/openai.yaml"

python3 -m json.tool "$ROOT/evals/evals.json" >/dev/null

echo "Validation passed."
