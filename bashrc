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
alias cdnvim='cd ~/.config/nvim/'

#######################################
# >>> Prompt
#######################################
PS1='[\u@\h \W]\$ '

#######################################
# >>> Environment variables
#######################################

# PATH - Local tools
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Directory colors (non-bold white)
export LS_COLORS="di=37:*di=*/"

#######################################
