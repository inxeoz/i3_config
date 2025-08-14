# i3 Desktop Environment Setup Guide

This repository contains a complete i3 window manager configuration with automated installation and setup scripts. The setup excludes nvim, sway configs, and starship as specified.

## Quick Start

1. **Clone or download this repository**
2. **Make scripts executable:**
   ```bash
   chmod +x setup_system.sh post_install_tweaks.sh
   ```
3. **Run the main setup script:**
   ```bash
   ./setup_system.sh
   ```
4. **Optionally run post-installation tweaks:**
   ```bash
   ./post_install_tweaks.sh
   ```
5. **Logout and login again, or run `startx` to start i3**

## What Gets Installed

### Core Window Manager
- **i3-wm** - Tiling window manager
- **i3status** - Status bar
- **i3lock** - Screen locker
- **polybar** - Advanced status bar (replaces i3status)
- **rofi** - Application launcher
- **dmenu** - Simple application launcher

### Terminals
- **alacritty** - GPU-accelerated terminal (primary)
- **kitty** - Feature-rich terminal (alternative)

### System Components
- **picom** - Compositor for transparency and effects
- **feh** - Wallpaper manager and image viewer
- **NetworkManager** - Network management
- **PulseAudio** - Audio system
- **Bluetooth** - Bluetooth stack (bluez, blueman)

### Utilities
- **flameshot** - Screenshot tool
- **htop** - System monitor
- **thunar** - File manager
- **ranger** - Terminal file manager
- **brightnessctl** - Brightness control
- **pavucontrol** - Audio mixer

### Development Tools
- **git** - Version control
- **curl, wget** - Download tools
- **bash-completion** - Enhanced bash completion

## Configuration Files

After installation, configuration files are located in:

```
~/.config/
├── i3/config                 # i3 window manager config
├── polybar/config.ini        # Status bar config
├── alacritty/alacritty.toml  # Primary terminal config
├── kitty/kitty.conf          # Alternative terminal config
├── picom/picom.conf          # Compositor config
└── rofi/config.rasi          # Application launcher config

~/.bashrc                     # Bash configuration
~/.xinitrc                    # X11 startup script
```

## Key Bindings

| Key Combination | Action |
|----------------|--------|
| `Mod4 + Return` | Open terminal (alacritty) |
| `Mod4 + d` | Open dmenu launcher |
| `Alt + Space` | Open rofi launcher |
| `Mod4 + c` | Close focused window |
| `Mod4 + f` | Toggle fullscreen |
| `Mod4 + Shift + Space` | Toggle floating mode |
| `Mod4 + h/v` | Split horizontal/vertical |
| `Mod4 + j/k/l/;` | Navigate windows |
| `Mod4 + Shift + j/k/l/;` | Move windows |
| `Mod4 + 1-9` | Switch to workspace |
| `Mod4 + Shift + 1-9` | Move window to workspace |
| `Mod4 + Shift + c` | Reload i3 config |
| `Mod4 + Shift + r` | Restart i3 |
| `Print` | Screenshot with flameshot |
| `XF86Audio*` | Volume controls |

**Note:** Mod4 is the Windows/Super key

## Post-Installation Utilities

After running `post_install_tweaks.sh`, you'll have access to:

| Command | Description |
|---------|-------------|
| `power-save` | Toggle CPU power saving mode |
| `display-config` | Configure displays (laptop/external/dual) |
| `input-config` | Configure keyboard and mouse settings |
| `lock-screen` | Lock screen with blur effect |
| `backup-configs` | Backup configuration files |
| `health-check` | System health check report |
| `sysinfo` | Quick system information |

### Bash Aliases Added
- `meminfo` - Show memory usage
- `diskusage` - Show disk usage
- `processes` - Show top CPU processes
- `temps` - Show system temperatures
- `syslog` - Follow system logs

## Supported Distributions

- **Arch Linux** (recommended)
- **Ubuntu/Debian** (partial support)
- **Fedora** (partial support)

## Directory Structure

The setup creates these directories:
```
~/
├── .config/          # Application configurations
├── .local/bin/       # User scripts
├── Pictures/Screenshots/  # Screenshot storage
├── Wallpaper/        # Wallpaper images
├── backups/          # Configuration backups
├── coding/           # Development projects
└── projects/         # General projects
```

## Customization

### Wallpapers
- Add images to `~/Wallpaper/`
- i3 will randomly select wallpapers on startup
- Use `feh --bg-scale /path/to/image` to set manually

### Themes
- Rofi: Edit `~/.config/rofi/config.rasi`
- Polybar: Edit `~/.config/polybar/config.ini`
- Terminal colors: Edit respective config files

### Keybindings
- Edit `~/.config/i3/config`
- Reload with `Mod4 + Shift + c`

## Troubleshooting

### Audio Issues
```bash
# Restart PulseAudio
pulseaudio --kill && pulseaudio --start

# Check audio devices
pactl list sinks short
```

### Display Issues
```bash
# Reconfigure displays
display-config dual    # For dual monitor
display-config laptop  # For laptop only
xrandr --auto          # Auto-detect displays
```

### Bluetooth Issues
```bash
# Fix bluetooth
fix_bt                 # Run bluetooth fix script
sudo systemctl restart bluetooth
```

### Performance Issues
```bash
# Check system health
health-check

# Enable power saving
power-save

# Check running processes
htop
```

## Security Notes

- UFW firewall is enabled (if available)
- Screen lock is configured with blur effect
- Configuration backups are created locally
- No remote access is configured by default

## Excluded Components

As requested, these components are **NOT** included:
- ❌ nvim configurations
- ❌ sway configurations  
- ❌ starship shell prompt

## Support

For issues:
1. Check the troubleshooting section above
2. Run `health-check` to diagnose system issues
3. Check logs with `journalctl -xe`
4. Verify configurations in `~/.config/`

## Updates

To update configurations:
1. Edit files in `~/.config/`
2. Reload i3 with `Mod4 + Shift + c`
3. Restart services if needed:
   ```bash
   ~/.config/polybar/launch.sh  # Restart polybar
   systemctl --user restart pulseaudio  # Restart audio
   ```

## Backup and Restore

### Backup
```bash
backup-configs  # Creates timestamped backup
```

### Restore
```bash
# Extract backup
cd ~/backups
tar -xzf configs-YYYY-MM-DD.tar.gz

# Copy desired configs back
cp -r configs-YYYY-MM-DD/.config/* ~/.config/
```

---

**Enjoy your new i3 desktop environment!** 🚀