function tmx
  set -l SESSION_NAME $argv[1]
  set -l DIRECTORY

  if test -z "$SESSION_NAME"
    set SESSION_NAME (basename (pwd))
  end

  if not tmux has-session -t $SESSION_NAME
    if test -d ./$SESSION_NAME
      set DIRECTORY $SESSION_NAME
    else
      if test -d ~/dev/$SESSION_NAME
        set DIRECTORY ~/dev/$SESSION_NAME
      else
        echo project directory not found
        return 1
      end
    end

    tmux new-session -d -c $DIRECTORY -s $SESSION_NAME
    tmux new-window -c $DIRECTORY -t $SESSION_NAME
    tmux split-window -h -c $DIRECTORY -t $SESSION_NAME
  end

  if test -z $TMUX
    tmux attach -t $SESSION_NAME
  else
    tmux switch -t $SESSION_NAME
  end
end
