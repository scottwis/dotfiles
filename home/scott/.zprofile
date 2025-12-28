export PATH="$PATH:/home/scott/.local/bin:/usr/local/go/bin:/home/scott/go/bin:/home/scott/.local/share/JetBrains/Toolbox/scripts"

export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share

if [[ -f ~/secrets.sh ]]; then
    source ~/secrets.sh
fi

export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt SHARE_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
export GOPRIVATE="github.com/debugging-sucks/*,github.com/plan42-api/*"
export EDITOR="emacs"

alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -out"
