function less
  if which bat > /dev/null
    command env BAT_PAGER="less -Ri" bat --theme=1337 $argv
  else
    command less -i $argv
  end
end
