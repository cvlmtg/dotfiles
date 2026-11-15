#!/bin/sh
# Prints what the implementer and the step reviewer of one plan step read: the
# plan's header and approach, the Design subsections the step lists, the step,
# the spec lines of every requirement and criterion it covers, the Consequences
# and Hot paths lines that cite them, the Locked Decisions, and the project's
# commands from context.md.
set -eu

[ $# -eq 2 ] || { echo "usage: step-brief.sh RUN STEP_NUMBER" >&2; exit 2; }
run=$1
n=$2
plan=$run/plan.md
spec=$run/spec.md

# Prepended to every awk program: `level` is the heading level of the current
# line, and 0 for any other line. A line inside a code fence is never a heading.
headings='
	/^[ \t]*```/ { fence = !fence }
	{ level = 0 }
	!fence && /^#+ / { level = index($0, " ") - 1 }'

# A section runs from its heading to the next heading of the same or a higher level.
section() {
	awk -v h="$1" "$headings"'
		level == 1 || level == 2 { if (on) exit; on = ($0 == h) }
		on' "$2"
}

step=$(awk -v n="$n" "$headings"'
	level >= 1 && level <= 3 { if (on) exit; on = (level == 3 && $2 == "Step" && $3 == n ":") }
	on' "$plan")
[ -n "$step" ] || { echo "step-brief: no step $n in $plan" >&2; exit 1; }

ids_of() { printf '%s\n' "$step" | sed -n "s/^- $1: //p" | tr -c 'A-Za-z0-9\n' ' '; }
design_ids=" $(ids_of Design) "
cover_ids=" $(ids_of Covers) "

awk "$headings"'level == 2 { exit } { print }' "$plan"
section "## Approach" "$plan"
echo
echo "## Design (subsections listed by step $n)"
awk -v ids="$design_ids" "$headings"'
	level == 1 || level == 2 { inside = ($0 == "## Design"); on = 0; next }
	inside && level == 3 { split($3, a, ":"); on = ($2 == "Design" && index(ids, " " a[1] " ") > 0) }
	on' "$plan"
echo
printf '%s\n\n' "$step"
echo "## Spec lines covered by step $n"
awk -v ids="$cover_ids" "$headings"'
	level == 2 { citing = ($0 == "## Consequences" || $0 == "## Hot paths"); next }
	!/^- / { next }
	match($0, /^- [A-Z]+[0-9]+[: ]/) && index(ids, " " substr($0, 3, RLENGTH - 3) " ") > 0 { print; next }
	citing {
		line = $0
		gsub(/[^A-Za-z0-9]/, " ", line)
		m = split(line, word, " ")
		for (i = 1; i <= m; i++) if (word[i] ~ /^[A-Z]+[0-9]+$/ && index(ids, " " word[i] " ") > 0) { print; next }
	}' "$spec"
echo
section "## Locked Decisions" "$spec"
echo
section "## Commands" "$run/context.md"
