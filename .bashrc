# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

export PATH=$PATH:/home/zen/.local/share/omarchy/bin
export PATH=$PATH:/home/zen/niribin

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
alias dotfiles='/usr/bin/git --git-dir=/home/zen/.dotfiles/ --work-tree=/home/zen'
