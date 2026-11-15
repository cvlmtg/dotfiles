#!/bin/sh
# Commits the whole working tree with the message under `## Commit message` in
# RUN/steps/STEP/report.md, followed by TRAILER when given. For a numbered plan
# step it then sets the step's Status line in plan.md to done. Prints the short
# hash. A hook that rejects the commit fails the script with the hook's output.
set -eu

[ $# -ge 2 ] && [ $# -le 3 ] || { echo "usage: commit-step.sh RUN STEP [TRAILER]" >&2; exit 2; }
run=$1
step=$2
report=$run/steps/$step/report.md
msg=$run/steps/$step/commit-msg.txt

awk '/^## Commit message/ { on = 1; next } on && /^## / { exit } on && !/^```/' "$report" > "$msg"
grep -q '[^[:space:]]' "$msg" || { echo "commit-step: no commit message in $report" >&2; exit 1; }
[ $# -eq 3 ] && printf '\n%s\n' "$3" >> "$msg"

git add -A
git commit -q -F "$msg"
hash=$(git rev-parse --short HEAD)

case $step in
*[!0-9]*) ;;
*)
	awk -v n="$step" -v h="$hash" '
		/^### Step [0-9]+:/ { on = ($3 == n ":") }
		on && /^- Status:/ { $0 = "- Status: done (" h ")"; on = 0 }
		{ print }' "$run/plan.md" > "$run/plan.md.tmp"
	mv "$run/plan.md.tmp" "$run/plan.md"
	;;
esac
echo "$hash"
