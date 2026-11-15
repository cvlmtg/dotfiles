#!/bin/sh
# Prints what the implementer and the step reviewer of one plan step read: the
# plan's header and approach, the Design subsections the step lists, the step,
# the spec lines of every requirement and criterion it covers, the Locked
# Decisions, and the project's commands from context.md.
set -eu

[ $# -eq 2 ] || { echo "usage: step-brief.sh RUN STEP_NUMBER" >&2; exit 2; }
run=$1
n=$2
plan=$run/plan.md
spec=$run/spec.md

# A section runs from its heading to the next heading of the same or a higher level.
section() {
	awk -v h="$1" '
		index($0, "## ") == 1 || index($0, "# ") == 1 { if (on) exit }
		$0 == h { on = 1 }
		on' "$2"
}

step=$(awk -v n="$n" '
	/^### Step [0-9]+:/ { if (on) exit; on = ($3 == n ":") }
	/^##? / { if (on) exit }
	on' "$plan")
[ -n "$step" ] || { echo "step-brief: no step $n in $plan" >&2; exit 1; }

ids_of() { printf '%s\n' "$step" | sed -n "s/^- $1: //p" | tr -c 'A-Za-z0-9\n' ' '; }
design_ids=" $(ids_of Design) "
cover_ids=" $(ids_of Covers) "

awk 'index($0, "## ") == 1 { exit } { print }' "$plan"
section "## Approach" "$plan"
echo
echo "## Design (subsections listed by step $n)"
awk -v ids="$design_ids" '
	/^##? / { inside = ($0 == "## Design"); on = 0; next }
	inside && /^### / { split($3, a, ":"); on = ($2 == "Design" && index(ids, " " a[1] " ") > 0) }
	on' "$plan"
echo
printf '%s\n\n' "$step"
echo "## Spec lines covered by step $n"
awk -v ids="$cover_ids" '
	match($0, /^- [A-Z]+[0-9]+[: ]/) { id = substr($0, 3, RLENGTH - 3); if (index(ids, " " id " ") > 0) print }' "$spec"
echo
section "## Locked Decisions" "$spec"
echo
section "## Commands" "$run/context.md"
