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

# questo serve per react-native

if test -d $HOME/Library/Android/sdk
  set -x ANDROID_HOME $HOME/Library/Android/sdk
  set PATH $PATH $ANDROID_HOME/emulator
  set PATH $PATH $ANDROID_HOME/tools
  set PATH $PATH $ANDROID_HOME/tools/bin
  set PATH $PATH $ANDROID_HOME/platform-tools
end

# questo serve per i deploy

if test -f ~/.ssh/bsl_deployer_rsa
  ssh-add -l | grep deployer > /dev/null

  if test $status -eq 1
    ssh-add -q
    ssh-add -q ~/.ssh/bsl_deployer_rsa
  end
end

# rimuoviamo il messaggio di benvenuto

set fish_greeting ""

# impostazioni varie

set -x RUBY_CONFIGURE_OPTS '--with-openssl-dir=/usr/local/opt/openssl@1.1'
set -x SHELL (which fish)

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

# nvm version manager for fish!

if test -d ~/.nvf; nvf init; end
