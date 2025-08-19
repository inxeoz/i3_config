# ~/.bashrc

cat() {
    if [ -d "$1" ]; then
        ls "$1"
    else
        command cat "$@"
    fi
}

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
export LANG=en_US.UTF-8


#######################################

##
## sudo pacman -S bash-completion

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# System monitoring aliases
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias diskusage='df -h'
alias processes='ps aux --sort=-%cpu | head -20'
alias netstat='ss -tuln'
alias temps='sensors 2>/dev/null || echo "Install lm-sensors for temperature monitoring"'
alias syslog='journalctl -f'

# Quick system info function
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory: $(free -h | awk '/^Mem/ {print $3"/"$2" ("$3/$2*100"%)"}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"
    if command -v sensors >/dev/null 2>&1; then
        echo "CPU Temp: $(sensors | grep 'Core 0' | awk '{print $3}' || echo 'N/A')"
    fi
}
