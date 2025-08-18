#!/bin/bash

# Arch Linux Configuration Backup Script
# This script copies configuration files from your Arch Linux system to this backup folder

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR"

# Logging functions
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

# Function to safely copy file with backup
safe_copy() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [[ -f "$src" ]]; then
        # Create backup if destination already exists
        if [[ -f "$dest" ]]; then
            cp "$dest" "$dest.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "Backed up existing $desc"
        fi

        cp "$src" "$dest"
        print_success "Copied $desc"
    else
        print_warning "$desc not found at $src"
    fi
}

# Function to safely copy directory with backup
safe_copy_dir() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [[ -d "$src" ]]; then
        # Create backup if destination already exists
        if [[ -d "$dest" ]]; then
            mv "$dest" "$dest.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "Backed up existing $desc directory"
        fi

        cp -r "$src" "$dest"
        print_success "Copied $desc directory"
    else
        print_warning "$desc directory not found at $src"
    fi
}

# Main backup function
backup_configs() {
    print_status "Starting configuration backup to: $BACKUP_DIR"
    echo

    # i3 Window Manager
    print_status "Backing up i3 configuration..."
    safe_copy "$HOME/.config/i3/config" "$BACKUP_DIR/configi3" "i3 config"

    # Sway Window Manager
    print_status "Backing up Sway configuration..."
    safe_copy "$HOME/.config/sway/config" "$BACKUP_DIR/configsway" "Sway config"

    # Polybar
    print_status "Backing up Polybar configuration..."
    safe_copy "$HOME/.config/polybar/config.ini" "$BACKUP_DIR/config.inipolybar" "Polybar config"

    # Rofi
    print_status "Backing up Rofi configuration..."
    safe_copy "$HOME/.config/rofi/config.rasi" "$BACKUP_DIR/config.rasi" "Rofi config"

    # Terminal Emulators
    print_status "Backing up terminal configurations..."
    safe_copy "$HOME/.config/alacritty/alacritty.toml" "$BACKUP_DIR/alacritty.toml" "Alacritty config"
    safe_copy "$HOME/.config/kitty/kitty.conf" "$BACKUP_DIR/kitty.conf" "Kitty config"

    # Picom (Compositor)
    print_status "Backing up Picom configuration..."
    safe_copy "$HOME/.config/picom/picom.conf" "$BACKUP_DIR/picom.conf" "Picom config"

    # Shell configurations
    print_status "Backing up shell configurations..."
    safe_copy "$HOME/.bashrc" "$BACKUP_DIR/bashrc" "Bashrc"
    safe_copy "$HOME/.zshrc" "$BACKUP_DIR/zshrc" "Zshrc"
    safe_copy "$HOME/.xinitrc" "$BACKUP_DIR/xinitrc" "Xinitrc"

    # Starship prompt
    print_status "Backing up Starship configuration..."
    safe_copy "$HOME/.config/starship.toml" "$BACKUP_DIR/starship.toml" "Starship config"

    # Neovim
    print_status "Backing up Neovim configuration..."
    if [[ -d "$HOME/.config/nvim" ]]; then
        safe_copy_dir "$HOME/.config/nvim" "$BACKUP_DIR/nvim" "Neovim config"
    fi

    # Git configuration
    print_status "Backing up Git configuration..."
    safe_copy "$HOME/.gitconfig" "$BACKUP_DIR/.gitconfig" "Git config"

    # SSH configuration
    print_status "Backing up SSH configuration..."
    if [[ -f "$HOME/.ssh/config" ]]; then
        mkdir -p "$BACKUP_DIR/.ssh"
        safe_copy "$HOME/.ssh/config" "$BACKUP_DIR/.ssh/config" "SSH config"
    fi

    # Fonts
    print_status "Backing up fonts..."
    if [[ -d "$HOME/.local/share/fonts" ]]; then
        safe_copy_dir "$HOME/.local/share/fonts" "$BACKUP_DIR/fonts" "Local fonts"
    fi

    # Custom scripts from .local/bin
    print_status "Backing up custom scripts..."
    if [[ -d "$HOME/.local/bin" ]]; then
        mkdir -p "$BACKUP_DIR/scripts"
        for script in "$HOME/.local/bin"/*; do
            if [[ -f "$script" && -x "$script" ]]; then
                script_name=$(basename "$script")
                cp "$script" "$BACKUP_DIR/scripts/$script_name"
                print_success "Copied script: $script_name"
            fi
        done
    fi

    # Wallpapers
    print_status "Backing up wallpapers..."
    if [[ -d "$HOME/Pictures/wallpapers" ]]; then
        safe_copy_dir "$HOME/Pictures/wallpapers" "$BACKUP_DIR/wallpapers" "Wallpapers"
    elif [[ -d "$HOME/.local/share/wallpapers" ]]; then
        safe_copy_dir "$HOME/.local/share/wallpapers" "$BACKUP_DIR/wallpapers" "Wallpapers"
    fi

    # Package lists
    print_status "Creating package lists..."
    if command -v pacman >/dev/null 2>&1; then
        pacman -Qqe > "$BACKUP_DIR/packages_explicit.txt"
        pacman -Qqm > "$BACKUP_DIR/packages_aur.txt" 2>/dev/null || touch "$BACKUP_DIR/packages_aur.txt"
        print_success "Created package lists"
    fi

    # System services
    print_status "Creating systemd service list..."
    systemctl --user list-unit-files --state=enabled --no-pager > "$BACKUP_DIR/systemd_user_enabled.txt" 2>/dev/null || true
    systemctl list-unit-files --state=enabled --no-pager | sudo tee "$BACKUP_DIR/systemd_system_enabled.txt" >/dev/null 2>&1 || true
    print_success "Created systemd service lists"

    # Additional application configs
    print_status "Backing up additional application configs..."

    # VSCode/Codium
    for editor in "Code" "VSCodium" "code" "codium"; do
        config_dir="$HOME/.config/$editor/User"
        if [[ -d "$config_dir" ]]; then
            mkdir -p "$BACKUP_DIR/vscode"
            safe_copy "$config_dir/settings.json" "$BACKUP_DIR/vscode/settings.json" "VSCode settings"
            safe_copy "$config_dir/keybindings.json" "$BACKUP_DIR/vscode/keybindings.json" "VSCode keybindings"
            if [[ -f "$config_dir/extensions.json" ]]; then
                safe_copy "$config_dir/extensions.json" "$BACKUP_DIR/vscode/extensions.json" "VSCode extensions"
            fi
            break
        fi
    done

    # Zsh plugins and themes (Oh My Zsh)
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        safe_copy "$HOME/.oh-my-zsh/custom" "$BACKUP_DIR/oh-my-zsh-custom" "Oh My Zsh custom"
    fi

    # Tmux
    safe_copy "$HOME/.tmux.conf" "$BACKUP_DIR/.tmux.conf" "Tmux config"

    # Create backup info file
    print_status "Creating backup information..."
    cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup created: $(date)
Hostname: $(hostname)
User: $(whoami)
Kernel: $(uname -r)
Distribution: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
Desktop Environment: ${XDG_CURRENT_DESKTOP:-Unknown}
Window Manager: ${DESKTOP_SESSION:-Unknown}

This backup was created using backup_configs.sh
EOF

    echo
    print_success "Configuration backup completed!"
    print_status "Backup location: $BACKUP_DIR"
    echo
    print_status "Files backed up:"
    find "$BACKUP_DIR" -type f -newer "$BACKUP_DIR/backup_info.txt" 2>/dev/null | sort || true
}

# Show help
show_help() {
    echo "Arch Linux Configuration Backup Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo "  -d, --dry-run  Show what would be backed up without copying"
    echo
    echo "This script backs up common configuration files from your Arch Linux system"
    echo "to the current directory. It creates backups of existing files before overwriting."
}

# Dry run function
dry_run() {
    echo "DRY RUN - Would backup the following files:"
    echo

    local files_to_check=(
        "$HOME/.config/i3/config:i3 config"
        "$HOME/.config/sway/config:Sway config"
        "$HOME/.config/polybar/config.ini:Polybar config"
        "$HOME/.config/rofi/config.rasi:Rofi config"
        "$HOME/.config/alacritty/alacritty.toml:Alacritty config"
        "$HOME/.config/kitty/kitty.conf:Kitty config"
        "$HOME/.config/picom/picom.conf:Picom config"
        "$HOME/.bashrc:Bashrc"
        "$HOME/.zshrc:Zshrc"
        "$HOME/.xinitrc:Xinitrc"
        "$HOME/.config/starship.toml:Starship config"
        "$HOME/.gitconfig:Git config"
        "$HOME/.ssh/config:SSH config"
        "$HOME/.tmux.conf:Tmux config"
    )

    for item in "${files_to_check[@]}"; do
        IFS=':' read -r file desc <<< "$item"
        if [[ -f "$file" ]]; then
            echo "  ✓ $desc ($file)"
        else
            echo "  ✗ $desc ($file) - NOT FOUND"
        fi
    done

    echo
    echo "Directories that would be backed up:"
    local dirs_to_check=(
        "$HOME/.config/nvim:Neovim config"
        "$HOME/.local/share/fonts:Local fonts"
        "$HOME/.local/bin:Custom scripts"
        "$HOME/Pictures/wallpapers:Wallpapers"
        "$HOME/.local/share/wallpapers:Wallpapers (alt location)"
    )

    for item in "${dirs_to_check[@]}"; do
        IFS=':' read -r dir desc <<< "$item"
        if [[ -d "$dir" ]]; then
            echo "  ✓ $desc ($dir)"
        else
            echo "  ✗ $desc ($dir) - NOT FOUND"
        fi
    done
}

# Parse command line arguments
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
if [[ "$DRY_RUN" == true ]]; then
    dry_run
else
    backup_configs
fi
