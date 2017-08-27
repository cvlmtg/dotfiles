function vim
  if [ -e /usr/local/bin/nvim ]
    nvim $argv
  else
    command vim $argv
  end
end
