export PATH="$PATH:/usr/local/go/bin:/home/scott/go/bin:/home/scott/.local/share/JetBrains/Toolbox/scripts"
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share

export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt SHARE_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
export GOPRIVATE="github.com/debugging-sucks/*"
export EDITOR="emacs"

alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -out"
