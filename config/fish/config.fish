function add_path
  # http://pgib.me/blog/2013/10/11/macosx-tmux-zsh-rbenv/
  # quando lanciamo TMUX il nostro $PATH viene modificato
  # da path_helper, per cui cerchiamo di sistemare le cose

  if test -d $argv
    if contains $argv $PATH
      set -l index (contains -i $argv $PATH)
      set -e PATH[$index]
    end
    set PATH $argv $PATH
  end
end

add_path ~/.rbenv/shims
add_path ~/.rbenv/bin
add_path ~/bin

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

if which nvim > /dev/null
  set -x SVN_EDITOR nvim
  set -x EDITOR nvim
  set -x VISUAL nvim
else
  set -x SVN_EDITOR vim
  set -x EDITOR vim
  set -x VISUAL vim
end

set -x SHELL (which fish)

# start stuff...

eval (brew shellenv)

if test -d ~/.nvf; nvf init; end
