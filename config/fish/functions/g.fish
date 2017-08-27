# git status (evitiamo gs per non mascherare ghostscript)

function g
  set -l has_staged_files (git status --porcelain ^/dev/null | egrep '^(M|A|D|R)' | wc -l)
  set -l has_files (git status --porcelain ^/dev/null | egrep '^ M' | wc -l)

  if test -n "$argv"
    set -l file $argv[1]

    if test -f "$file" -o -d "$file"
      git add $argv
    else
      git $argv
    end
    return
  end

  if test $has_staged_files -gt 0
    git diff --staged
    git status
    return
  end

  if test $has_files -gt 0
    if test -n "$argv"
      git diff $argv
    else
      git diff
      git status
    end
    return
  end

  git status
end
