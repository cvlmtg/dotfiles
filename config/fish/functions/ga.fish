# git add -A
# git commit --amend

function ga
  set -l has_staged_files (git status --porcelain ^/dev/null | egrep '^(M|A|D|R)' | wc -l)

  if test $has_staged_files -eq 0
    git add -A
  end

  git commit --amend
end
