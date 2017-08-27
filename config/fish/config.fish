# sotto osx /usr/local/bin viene dopo /usr/bin...
set -l local_index (contains -i /usr/local/bin $PATH)
set -l usr_index   (contains -i /usr/bin $PATH)

if test $local_index -gt $usr_index
  set -e PATH[$local_index]
  set PATH /usr/local/bin $PATH
end

# usiamo rbenv invece di rvm
if test -d ~/.rbenv
  if test -d ~/.rbenv/bin
    set PATH "$HOME/.rbenv/bin" $PATH
  end
  if not contains ~/.rbenv/shims $PATH
    set PATH "$HOME/.rbenv/shims" $PATH
  end
end

if test -x /usr/local/bin/fish
  set -x SHELL /usr/local/bin/fish
else
  set -x SHELL /usr/bin/fish
end

if not contains ~/bin $PATH
  set PATH ~/bin $PATH
end

# rimuoviamo il messaggio di benvenuto
set fish_greeting ""

# impostazioni varie
set -x FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!.git/*"'

if which pygmentize > /dev/null
  set -x LESSOPEN '| pygmentize -f 256 -O encoding=utf-8,style=monokai "%s"'
end
set -x LESS '-R -i'

set -x SVN_EDITOR nvim
set -x EDITOR nvim
set -x VISUAL nvim

# nvm version manager for fish!
if test -d ~/.nvf; nvf init; end
