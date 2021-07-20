function less
  if which bat > /dev/null
    command bat --theme=1337 $argv
  else
    command less -i $argv
  end
end
