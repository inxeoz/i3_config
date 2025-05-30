# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto --classify'
alias grep='grep --color=auto'
alias cdc='cd ~/coding'
alias cdd='cd ~/Documents'
alias cddd='cd ~/Downloads'
alias cdt='cd ~/Temp'

# Prompt settings
PS1='[\u@\h \W]\$ '

# Starship prompt initialization
eval "$(starship init bash)"


# Set directory color to white
#export LS_COLORS="di=01;37:*di=*/"

# Set directory color to non-bold white
export LS_COLORS="di=37:*di=*/"
export PATH="$HOME/.cargo/bin:$PATH"

##### i am using n package from npm
####export NVM_DIR="$HOME/.nvm"
####[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
####[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#. "$HOME/.local/bin/env"

export ANDROID_HOME=$HOME/Android/Sdk
#export PATH=$PATH:/home/inxeoz/.nvm/versions/node/v18.20.8/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:$ANDROID_HOME/platform-tools

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.13113456"

export CAPACITOR_ANDROID_STUDIO_PATH="/home/inxeoz/.local/share/JetBrains/Toolbox/apps/android-studio/bin/studio.sh"

# pnpm
export PNPM_HOME="/home/inxeoz/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
