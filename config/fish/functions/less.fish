function less
  set -l OPEN '| pygmentize -f 256 -O encoding=utf-8,style=monokai "%s"'
  set -l MATCH (string match -iq '*.min.*' -- "$argv"; echo $status)
  set -l COUNT (count $argv)
  set -x LESS '-R -i'

  if test $MATCH -eq 0
    command less $argv
  else
    if which pygmentize > /dev/null
      env LESSOPEN="$OPEN" command less $argv
    else
      command less $argv
    end
  end
end
