# git commit -m 'blabla'

function gc
  set -l has_staged_files (git status --porcelain ^/dev/null | egrep '^(M|A|D|R)' | wc -l)
  set -l has_files (git status --porcelain ^/dev/null | egrep '^( M|\?\?)' | wc -l)

  if test $has_staged_files -gt 0
    if test -n "$argv"
      git commit -m "$argv"
    else
      git commit
    end
    return
  end

  if test $has_files -gt 0
    git add -A

    if test -n "$argv"
      git commit -m "$argv"
    else
      git commit
    end
    return
  end

  git commit -m 'show git error message'
end
