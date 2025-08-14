#!/bin/bash

# ===============================================================================
# Comprehensive i3 System Setup Script
# Installs packages and configures the complete i3 desktop environment
# Excludes: nvim, sway configs, starship
# ===============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Detect package manager and distro
detect_system() {
    if command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
        DISTRO="arch"
        INSTALL_CMD="sudo pacman -S --needed --noconfirm"
        UPDATE_CMD="sudo pacman -Syu --noconfirm"
    elif command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
        DISTRO="debian"
        INSTALL_CMD="sudo apt install -y"
        UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
        DISTRO="fedora"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf update -y"
    else
        print_error "Unsupported package manager. This script supports pacman, apt, and dnf."
        exit 1
    fi
    print_status "Detected $DISTRO system with $PKG_MANAGER"
}

# Update system
update_system() {
    print_status "Updating system packages..."
    $UPDATE_CMD
    print_success "System updated"
}

# Install packages based on distro
install_packages() {
    print_status "Installing required packages..."

    if [[ $DISTRO == "arch" ]]; then
        # Core packages
        local packages=(
            # Window manager and utilities
            "i3-wm" "i3status" "i3lock" "xss-lock" "dex"

            # Terminals
            "alacritty" "kitty"

            # Compositor and visual effects
            "picom" "feh"

            # Status bar
            "polybar"

            # Application launchers
            "rofi" "dmenu"

            # Audio
            "pulseaudio" "pulseaudio-alsa" "pavucontrol" "pamixer"

            # Network
            "network-manager-applet" "networkmanager"

            # Power management
            "xfce4-power-manager"

            # Screenshot tools
            "flameshot" "imagemagick" "xclip"

            # System monitoring
            "htop" "brightnessctl"

            # Bluetooth
            "blueman" "bluez" "bluez-utils"

            # Fonts
            "ttf-jetbrains-mono" "ttf-liberation" "noto-fonts"

            # File management
            "ranger" "thunar"

            # Development tools
            "git" "curl" "wget" "unzip"

            # System utilities
            "bash-completion" "xdg-utils" "xorg-xrandr" "xorg-xinit"
        )

        $INSTALL_CMD "${packages[@]}"

    elif [[ $DISTRO == "debian" ]]; then
        # Update package lists
        sudo apt update

        local packages=(
            # Window manager and utilities
            "i3-wm" "i3status" "i3lock" "xss-lock" "dex"

            # Terminals
            "alacritty" "kitty"

            # Compositor and visual effects
            "picom" "feh"

            # Application launchers
            "rofi" "dmenu"

            # Audio
            "pulseaudio" "pulseaudio-utils" "pavucontrol"

            # Network
            "network-manager-gnome"

            # Power management
            "xfce4-power-manager"

            # Screenshot tools
            "flameshot" "imagemagick" "xclip"

            # System monitoring
            "htop"

            # Bluetooth
            "blueman" "bluetooth"

            # Fonts
            "fonts-jetbrains-mono" "fonts-liberation"

            # File management
            "ranger" "thunar"

            # Development tools
            "git" "curl" "wget" "unzip"

            # System utilities
            "bash-completion" "xdg-utils" "x11-xserver-utils" "xinit"
        )

        $INSTALL_CMD "${packages[@]}"

        # Install polybar from source or PPA if not available
        if ! command -v polybar >/dev/null 2>&1; then
            print_status "Installing polybar dependencies..."
            sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev \
                libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev \
                libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev \
                pkg-config python3-xcbgen xcb-proto libxcb-xrm-dev \
                libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev \
                libpulse-dev libxcb-composite0-dev xcb libxcb-ewmh2
        fi

    elif [[ $DISTRO == "fedora" ]]; then
        local packages=(
            # Window manager and utilities
            "i3" "i3status" "i3lock" "xss-lock" "dex"

            # Terminals
            "alacritty" "kitty"

            # Compositor and visual effects
            "picom" "feh"

            # Status bar
            "polybar"

            # Application launchers
            "rofi" "dmenu"

            # Audio
            "pulseaudio" "pulseaudio-utils" "pavucontrol"

            # Network
            "network-manager-applet"

            # Power management
            "xfce4-power-manager"

            # Screenshot tools
            "flameshot" "ImageMagick" "xclip"

            # System monitoring
            "htop"

            # Bluetooth
            "blueman" "bluez"

            # Fonts
            "jetbrains-mono-fonts" "liberation-fonts"

            # File management
            "ranger" "thunar"

            # Development tools
            "git" "curl" "wget" "unzip"

            # System utilities
            "bash-completion" "xdg-utils" "xorg-x11-server-utils" "xinit"
        )

        $INSTALL_CMD "${packages[@]}"
    fi

    print_success "Packages installed successfully"
}

# Create necessary directories
create_directories() {
    print_status "Creating configuration directories..."

    local dirs=(
        "$HOME/.config/i3"
        "$HOME/.config/polybar"
        "$HOME/.config/alacritty"
        "$HOME/.config/kitty"
        "$HOME/.config/picom"
        "$HOME/.config/rofi"
        "$HOME/Pictures/Screenshots"
        "$HOME/Wallpaper"
        "$HOME/.local/bin"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_status "Created directory: $dir"
        fi
    done

    print_success "Directories created"
}

# Copy configuration files
copy_configs() {
    print_status "Copying configuration files..."

    local script_dir="$(dirname "$(readlink -f "$0")")"

    # i3 configuration
    if [[ -f "$script_dir/configi3" ]]; then
        cp "$script_dir/configi3" "$HOME/.config/i3/config"
        print_status "Copied i3 config"
    fi

    # Polybar configuration
    if [[ -f "$script_dir/config.inipolybar" ]]; then
        cp "$script_dir/config.inipolybar" "$HOME/.config/polybar/config.ini"
        print_status "Copied polybar config"
    fi

    # Alacritty configuration
    if [[ -f "$script_dir/alacritty.toml" ]]; then
        cp "$script_dir/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
        print_status "Copied alacritty config"
    fi

    # Kitty configuration
    if [[ -f "$script_dir/kitty.conf" ]]; then
        cp "$script_dir/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        print_status "Copied kitty config"
    fi

    # Picom configuration
    if [[ -f "$script_dir/picom.conf" ]]; then
        mkdir -p "$HOME/.config/picom"
        cp "$script_dir/picom.conf" "$HOME/.config/picom/picom.conf"
        print_status "Copied picom config"
    fi

    # Rofi configuration
    if [[ -f "$script_dir/config.rasi" ]]; then
        cp "$script_dir/config.rasi" "$HOME/.config/rofi/config.rasi"
        print_status "Copied rofi config"
    fi

    # Bashrc
    if [[ -f "$script_dir/bashrc" ]]; then
        cp "$script_dir/bashrc" "$HOME/.bashrc"
        print_status "Copied bashrc"
    fi

    # Xinitrc
    if [[ -f "$script_dir/xinitrc" ]]; then
        cp "$script_dir/xinitrc" "$HOME/.xinitrc"
        chmod +x "$HOME/.xinitrc"
        print_status "Copied xinitrc"
    fi

    print_success "Configuration files copied"
}

# Create polybar launch script
create_polybar_launch() {
    print_status "Creating polybar launch script..."

    cat > "$HOME/.config/polybar/launch.sh" << 'EOF'
#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload example &
  done
else
  polybar --reload example &
fi
EOF

    chmod +x "$HOME/.config/polybar/launch.sh"
    print_success "Polybar launch script created"
}

# Set up services
setup_services() {
    print_status "Setting up system services..."

    # Enable NetworkManager
    if systemctl list-unit-files | grep -q NetworkManager; then
        sudo systemctl enable NetworkManager
        sudo systemctl start NetworkManager
        print_status "NetworkManager enabled"
    fi

    # Enable Bluetooth
    if systemctl list-unit-files | grep -q bluetooth; then
        sudo systemctl enable bluetooth
        sudo systemctl start bluetooth
        print_status "Bluetooth enabled"
    fi

    print_success "Services configured"
}

# Create default wallpaper directory with a sample
setup_wallpapers() {
    print_status "Setting up wallpapers..."

    if [[ ! -d "$HOME/Wallpaper" ]]; then
        mkdir -p "$HOME/Wallpaper"
    fi

    # Create a simple default wallpaper if none exists
    if [[ ! "$(ls -A $HOME/Wallpaper 2>/dev/null)" ]]; then
        # Create a simple colored wallpaper using ImageMagick
        if command -v convert >/dev/null 2>&1; then
            convert -size 1920x1080 gradient:"#2e3440"-"#5e81ac" "$HOME/Wallpaper/default.png"
            print_status "Created default wallpaper"
        fi
    fi

    print_success "Wallpapers configured"
}

# Create useful scripts
create_scripts() {
    print_status "Creating utility scripts..."

    # Bluetooth headphone script
    if [[ -f "$(dirname "$(readlink -f "$0")")/bt_headphone" ]]; then
        cp "$(dirname "$(readlink -f "$0")")/bt_headphone" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/bt_headphone"
    fi

    # Bluetooth fix script
    if [[ -f "$(dirname "$(readlink -f "$0")")/fix_bt" ]]; then
        cp "$(dirname "$(readlink -f "$0")")/fix_bt" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/fix_bt"
    fi

    # WiFi fix script
    if [[ -f "$(dirname "$(readlink -f "$0")")/fix_iwctl" ]]; then
        cp "$(dirname "$(readlink -f "$0")")/fix_iwctl" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/fix_iwctl"
    fi

    print_success "Utility scripts created"
}

# Final setup and information
final_setup() {
    print_status "Performing final setup..."

    # Source bashrc in current session
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
    fi

    # Make sure .local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    print_success "Setup completed successfully!"
    echo
    print_status "=== SETUP SUMMARY ==="
    echo "✓ System packages installed"
    echo "✓ Configuration files copied"
    echo "✓ Directory structure created"
    echo "✓ Services enabled"
    echo "✓ Utility scripts installed"
    echo
    print_warning "NEXT STEPS:"
    echo "1. Logout and login again, or run 'startx' to start i3"
    echo "2. Press Mod4+Return to open terminal"
    echo "3. Press Mod4+d for dmenu or Alt+Space for rofi"
    echo "4. Press Mod4+Shift+c to reload i3 config"
    echo "5. Add wallpapers to ~/Wallpaper/ directory"
    echo
    print_status "Excluded from setup: nvim configs, sway configs, starship"
    print_status "Configuration files are located in ~/.config/"
}

# Main execution
main() {
    echo "==============================================================================="
    echo "                    i3 Desktop Environment Setup Script                       "
    echo "==============================================================================="
    echo

    detect_system

    print_status "This script will:"
    echo "  • Install i3 window manager and related packages"
    echo "  • Configure terminals (alacritty, kitty)"
    echo "  • Set up polybar status bar"
    echo "  • Configure compositor (picom)"
    echo "  • Install application launchers (rofi, dmenu)"
    echo "  • Set up audio, bluetooth, and power management"
    echo "  • Copy configuration files"
    echo "  • Create utility scripts"
    echo
    print_warning "Excluded: nvim configs, sway configs, starship"
    echo

    read -p "Continue with installation? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_status "Installation cancelled"
        exit 0
    fi

    update_system
    install_packages
    create_directories
    copy_configs
    create_polybar_launch
    setup_services
    setup_wallpapers
    create_scripts
    final_setup
}

# Run main function
main "$@"
