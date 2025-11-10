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
export OPENAI_API_KEY=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

alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -out"
