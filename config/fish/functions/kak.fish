function kak
  if test -z "$TMUX"
    tmux new-session -As kakoune command kak $argv
  else
    kak $argv
  end
end
