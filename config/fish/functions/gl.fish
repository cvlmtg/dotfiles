# git log -u FILENAME
# git log

function gl
  set -f FILENAME $argv[1]

  if test "z$FILENAME" = "z--"
    set FILENAME $argv[2]
  end

  if test -n "$FILENAME"
    git log --full-history --follow -u -- $FILENAME
  else
    git log
  end
end
