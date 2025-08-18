# ~/.bashrc

# Exit early if not running interactively
[[ $- != *i* ]] && return

#######################################
# >>> Aliases
#######################################
alias ls='ls --color=auto --classify'
alias grep='grep --color=auto'
alias cdc='cd ~/coding'
alias cdd='cd ~/Downloads'
alias cdt='cd ~/Temp'

#######################################
# >>> Prompt
#######################################
PS1='[\u@\h \W | $(date "+%I:%M:%S %p")]\$ '
#######################################
# >>> Environment variables
#######################################

# PATH - Local tools
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Directory colors (non-bold white)
export LS_COLORS="di=37:*di=*/"
export PATH=~/.npm-global/bin:$PATH
export PATH="$HOME/.nvm:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

#######################################

##
## sudo pacman -S bash-completion

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
