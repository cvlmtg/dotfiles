# tr serve perché sotto tmux appaiono dei caratteri
# di controllo che non si vedono nelle shell normali
function rg
  if which bat > /dev/null
    set PAGER "bat -p"
  else
    set PAGER "less -R"
  end

  if isatty stdout
    command rg --smart-case --heading --pretty -g "!*.min.js" -g "!*.map" $argv | tr -d "\017" | eval $PAGER
  else
    command rg $argv
  end
end
