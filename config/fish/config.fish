# sotto osx /usr/local/bin viene dopo /usr/bin...
set -l local_index (contains -i /usr/local/bin $PATH)
set -l usr_index   (contains -i /usr/bin $PATH)

if test $local_index -gt $usr_index
  set -e PATH[$local_index]
  set PATH /usr/local/bin $PATH
end

# per i pacchetti python installati con 'pip install --user'
if test -d ~/Library/Python/2.7/bin
  set PATH ~/Library/Python/2.7/bin $PATH
end

# usiamo rbenv invece di rvm
if test -d ~/.rbenv/bin
  set PATH "$HOME/.rbenv/bin" $PATH
end
if test -d ~/.rbenv/shims
  if not contains ~/.rbenv/shims $PATH
    set PATH "$HOME/.rbenv/shims" $PATH
  end
end

if test -d ~/bin
  if not contains ~/bin $PATH
    set PATH ~/bin $PATH
  end
end

# rimuoviamo il messaggio di benvenuto
set fish_greeting ""

# impostazioni varie
if which fd > /dev/null
  set -x FZF_DEFAULT_COMMAND 'fd --hidden --exclude ".git/"'
  set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
  set -x FZF_ALT_C_COMMAND "fd -t d"
else
  set -x FZF_DEFAULT_COMMAND 'rg --files --follow --hidden --glob "!.git/*"'
end

if which pygmentize > /dev/null
  set -x LESSOPEN '| pygmentize -f 256 -O encoding=utf-8,style=monokai "%s"'
end
set -x LESS '-R -i'

set -x SHELL (which fish)

if which nvim > /dev/null
  set -x SVN_EDITOR nvim
  set -x EDITOR nvim
  set -x VISUAL nvim
else
  set -x SVN_EDITOR vim
  set -x EDITOR vim
  set -x VISUAL vim
end

# nvm version manager for fish!
if test -d ~/.nvf; nvf init; end
