# git log -u FILENAME
# git log

function gl
  set -l FILENAME $argv[1]

  if test -n "$FILENAME"
    git log --all --full-history -u $FILENAME
  else
    git log
  end
end
