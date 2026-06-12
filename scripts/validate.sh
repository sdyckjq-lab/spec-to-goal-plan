#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ruby -e '
  require "yaml"

  path = ARGV.fetch(0)
  text = File.read(path, encoding: "UTF-8")
  abort "SKILL.md must start with YAML frontmatter" unless text.start_with?("---\n")

  parts = text.split("---\n", 3)
  abort "SKILL.md frontmatter is incomplete" unless parts.length == 3

  metadata = YAML.safe_load(parts[1])
  abort "SKILL.md frontmatter is missing name" unless metadata["name"]
  abort "SKILL.md frontmatter is missing description" unless metadata["description"]
  abort "Unexpected Skill name: #{metadata["name"]}" unless metadata["name"] == "spec-to-goal-plan"
  abort "SKILL.md name exceeds 64 chars" if metadata["name"].length > 64
  abort "SKILL.md description exceeds 1024 chars (#{metadata["description"].length})" if metadata["description"].length > 1024
  abort "SKILL.md body is empty" if parts[2].strip.empty?

  body_lines = parts[2].lines.length
  abort "SKILL.md body exceeds 500 lines (#{body_lines})" if body_lines > 500
' "$ROOT/SKILL.md"

ruby -e '
  require "yaml"

  metadata = YAML.safe_load(File.read(ARGV.fetch(0), encoding: "UTF-8"))
  interface = metadata["interface"]
  abort "agents/openai.yaml is missing the interface section" unless interface
  %w[display_name short_description default_prompt].each do |key|
    abort "agents/openai.yaml is missing interface.#{key}" unless interface[key]
  end
  abort "interface.default_prompt must mention $spec-to-goal-plan" unless interface["default_prompt"].include?("$spec-to-goal-plan")
  len = interface["short_description"].length
  abort "interface.short_description should be 25-64 chars (#{len})" unless (25..64).cover?(len)
' "$ROOT/agents/openai.yaml"

for ref in phased-plan.md checklist-ledger.md; do
  [ -f "$ROOT/references/$ref" ] || { echo "Missing references/$ref" >&2; exit 1; }
done

python3 -m json.tool "$ROOT/evals/evals.json" >/dev/null

echo "Validation passed."
