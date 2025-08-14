#!/bin/bash

# ===============================================================================
# Post-Installation Tweaks and Optimizations Script
# Additional configurations and optimizations for i3 desktop environment
# Run this after the main setup script
# ===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Optimize system performance
optimize_system() {
    print_status "Applying system optimizations..."

    # Create swappiness configuration
    echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null

    # Optimize I/O scheduler for SSDs
    if [[ -f /sys/block/nvme0n1/queue/scheduler ]]; then
        echo 'ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"' | \
            sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null
    fi

    print_success "System optimizations applied"
}

# Configure audio improvements
setup_audio_tweaks() {
    print_status "Configuring audio improvements..."

    # Create PulseAudio configuration directory
    mkdir -p "$HOME/.config/pulse"

    # Improve audio quality
    cat > "$HOME/.config/pulse/daemon.conf" << 'EOF'
# Audio quality improvements
default-sample-format = float32le
default-sample-rate = 48000
alternate-sample-rate = 44100
default-sample-channels = 2
default-channel-map = front-left,front-right
resample-method = speex-float-3
enable-lfe-remixing = no
high-priority = yes
nice-level = -11
realtime-scheduling = yes
realtime-priority = 5
rlimit-rtprio = 9
daemonize = no
EOF

    print_success "Audio configuration optimized"
}

# Set up development environment basics
setup_dev_environment() {
    print_status "Setting up development environment basics..."

    # Create common development directories
    mkdir -p "$HOME/coding" "$HOME/projects" "$HOME/scripts"

    # Set up Git if not configured
    if ! git config --global user.name >/dev/null 2>&1; then
        print_warning "Git user.name not set. Configure with: git config --global user.name 'Your Name'"
    fi

    if ! git config --global user.email >/dev/null 2>&1; then
        print_warning "Git user.email not set. Configure with: git config --global user.email 'your.email@example.com'"
    fi

    # Create useful git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.lg "log --oneline --graph --decorate --all"

    print_success "Development environment basics configured"
}

# Configure power management
setup_power_management() {
    print_status "Configuring power management..."

    # Create power management scripts
    mkdir -p "$HOME/.local/bin"

    # Battery optimization script
    cat > "$HOME/.local/bin/power-save" << 'EOF'
#!/bin/bash
# Toggle power saving mode

if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null) == "powersave" ]]; then
    echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    echo "Performance mode enabled"
else
    echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    echo "Power save mode enabled"
fi
EOF

    chmod +x "$HOME/.local/bin/power-save"

    print_success "Power management configured"
}

# Configure display and graphics
setup_display_tweaks() {
    print_status "Configuring display optimizations..."

    # Create xrandr script for common display configurations
    cat > "$HOME/.local/bin/display-config" << 'EOF'
#!/bin/bash
# Display configuration helper

case "$1" in
    "external")
        xrandr --auto
        xrandr --output eDP-1 --off
        echo "External display only"
        ;;
    "dual")
        xrandr --auto
        xrandr --output eDP-1 --primary --output HDMI-1 --right-of eDP-1 2>/dev/null || \
        xrandr --output eDP-1 --primary --output DP-1 --right-of eDP-1 2>/dev/null
        echo "Dual display setup"
        ;;
    "laptop")
        xrandr --output eDP-1 --primary --auto
        xrandr --output HDMI-1 --off 2>/dev/null || true
        xrandr --output DP-1 --off 2>/dev/null || true
        echo "Laptop display only"
        ;;
    *)
        echo "Usage: $0 {external|dual|laptop}"
        echo "  external - Use external monitor only"
        echo "  dual     - Use both laptop and external monitor"
        echo "  laptop   - Use laptop screen only"
        ;;
esac
EOF

    chmod +x "$HOME/.local/bin/display-config"

    print_success "Display configuration script created"
}

# Set up keyboard and input optimizations
setup_input_tweaks() {
    print_status "Configuring input optimizations..."

    # Create keyboard configuration
    cat > "$HOME/.Xmodmap" << 'EOF'
! Keyboard optimizations
! Swap Caps Lock and Escape for better vim/programming experience
! Uncomment the next line if you want this behavior
! clear Lock
! keycode 9 = Caps_Lock NoSymbol Caps_Lock
! keycode 66 = Escape NoSymbol Escape
EOF

    # Create input configuration script
    cat > "$HOME/.local/bin/input-config" << 'EOF'
#!/bin/bash
# Input device configuration

# Set keyboard repeat rate
xset r rate 300 50

# Disable touchpad while typing (if available)
if command -v syndaemon >/dev/null 2>&1; then
    syndaemon -i 1.0 -t -K -R &
fi

# Configure mouse acceleration
xinput --set-prop "pointer" "libinput Accel Speed" -0.5 2>/dev/null || true

echo "Input devices configured"
EOF

    chmod +x "$HOME/.local/bin/input-config"

    print_success "Input optimizations configured"
}

# Create system monitoring aliases and functions
setup_monitoring_tools() {
    print_status "Setting up system monitoring tools..."

    # Add monitoring aliases to bashrc if not already present
    if ! grep -q "# System monitoring aliases" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

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
EOF
    fi

    print_success "System monitoring tools configured"
}

# Configure security basics
setup_security_basics() {
    print_status "Configuring basic security settings..."

    # Set up firewall if ufw is available
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force enable
        print_status "UFW firewall enabled"
    fi

    # Create screen lock script
    cat > "$HOME/.local/bin/lock-screen" << 'EOF'
#!/bin/bash
# Enhanced screen lock with blur effect

# Take screenshot and blur it
scrot /tmp/screen_locked.png
convert /tmp/screen_locked.png -blur 0x5 /tmp/screen_locked.png

# Lock screen with blurred background
i3lock -i /tmp/screen_locked.png --nofork

# Clean up
rm -f /tmp/screen_locked.png
EOF

    chmod +x "$HOME/.local/bin/lock-screen"

    print_success "Security basics configured"
}

# Set up backup basics
setup_backup_basics() {
    print_status "Setting up backup basics..."

    # Create backup script template
    cat > "$HOME/.local/bin/backup-configs" << 'EOF'
#!/bin/bash
# Basic configuration backup script

BACKUP_DIR="$HOME/backups/configs/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# Backup important configs
cp -r "$HOME/.config" "$BACKUP_DIR/" 2>/dev/null || true
cp "$HOME/.bashrc" "$BACKUP_DIR/" 2>/dev/null || true
cp "$HOME/.xinitrc" "$BACKUP_DIR/" 2>/dev/null || true

# Create archive
cd "$HOME/backups"
tar -czf "configs-$(date +%Y-%m-%d).tar.gz" "configs/$(date +%Y-%m-%d)"
rm -rf "configs/$(date +%Y-%m-%d)"

echo "Backup created: $HOME/backups/configs-$(date +%Y-%m-%d).tar.gz"
EOF

    chmod +x "$HOME/.local/bin/backup-configs"
    mkdir -p "$HOME/backups"

    print_success "Backup system configured"
}

# Create system health check script
create_health_check() {
    print_status "Creating system health check script..."

    cat > "$HOME/.local/bin/health-check" << 'EOF'
#!/bin/bash
# System health check script

echo "=== System Health Check ==="
echo "Date: $(date)"
echo

# Check disk space
echo "=== Disk Usage ==="
df -h | grep -E '^(/dev/|Filesystem)' | sort

# Check memory usage
echo -e "\n=== Memory Usage ==="
free -h

# Check load average
echo -e "\n=== Load Average ==="
uptime

# Check failed services
echo -e "\n=== Failed Services ==="
systemctl --failed --no-pager 2>/dev/null || echo "systemd not available"

# Check journal errors
echo -e "\n=== Recent Journal Errors ==="
journalctl -p err -n 5 --no-pager 2>/dev/null || echo "journalctl not available"

# Check battery if available
if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    echo -e "\n=== Battery Status ==="
    echo "Capacity: $(cat /sys/class/power_supply/BAT0/capacity)%"
    echo "Status: $(cat /sys/class/power_supply/BAT0/status)"
fi

# Check network connectivity
echo -e "\n=== Network Connectivity ==="
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "Internet: Connected"
else
    echo "Internet: Disconnected"
fi

echo -e "\n=== Health Check Complete ==="
EOF

    chmod +x "$HOME/.local/bin/health-check"

    print_success "Health check script created"
}

# Final tweaks and optimizations
apply_final_tweaks() {
    print_status "Applying final tweaks..."

    # Ensure all scripts are executable
    find "$HOME/.local/bin" -type f -exec chmod +x {} \; 2>/dev/null

    # Update font cache
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -fv >/dev/null 2>&1
    fi

    # Create desktop entries for custom scripts
    mkdir -p "$HOME/.local/share/applications"

    cat > "$HOME/.local/share/applications/system-monitor.desktop" << 'EOF'
[Desktop Entry]
Name=System Monitor
Comment=Quick system monitoring
Exec=kitty -e htop
Icon=utilities-system-monitor
Type=Application
Categories=System;Monitor;
EOF

    print_success "Final tweaks applied"
}

# Main execution function
main() {
    echo "==============================================================================="
    echo "                    Post-Installation Tweaks and Optimizations               "
    echo "==============================================================================="
    echo

    print_status "This script will apply additional optimizations and tweaks:"
    echo "  • System performance optimizations"
    echo "  • Audio quality improvements"
    echo "  • Development environment setup"
    echo "  • Power management configuration"
    echo "  • Display and input optimizations"
    echo "  • System monitoring tools"
    echo "  • Security basics"
    echo "  • Backup utilities"
    echo "  • Health check scripts"
    echo

    read -p "Continue with post-installation tweaks? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_status "Post-installation tweaks cancelled"
        exit 0
    fi

    optimize_system
    setup_audio_tweaks
    setup_dev_environment
    setup_power_management
    setup_display_tweaks
    setup_input_tweaks
    setup_monitoring_tools
    setup_security_basics
    setup_backup_basics
    create_health_check
    apply_final_tweaks

    echo
    print_success "Post-installation tweaks completed successfully!"
    echo
    print_status "=== NEW UTILITIES AVAILABLE ==="
    echo "• power-save          - Toggle CPU power saving"
    echo "• display-config      - Configure displays (laptop/external/dual)"
    echo "• input-config        - Configure keyboard and mouse"
    echo "• lock-screen         - Lock screen with blur effect"
    echo "• backup-configs      - Backup configuration files"
    echo "• health-check        - System health check"
    echo "• sysinfo             - Quick system information (bash function)"
    echo
    print_warning "NOTES:"
    echo "• Source ~/.bashrc or restart terminal for new aliases"
    echo "• Some optimizations require a reboot to take full effect"
    echo "• Configure git user.name and user.email if not already set"
    echo "• Install lm-sensors for temperature monitoring"
    echo
    print_status "All utilities are located in ~/.local/bin/"
}

# Run main function
main "$@"
