function ssh
    # se facciamo un ssh su qualche server mentre siamo sotto tmux,
    # succede che $TERM rimane impostato a screen-256color
    env TERM=xterm-256color ssh $argv
end
