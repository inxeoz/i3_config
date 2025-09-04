#!/bin/bash
# start_backup.sh - Copy config files from home to current folder, renaming dotfiles for git tracking

# Default values
ROOT="$HOME"
OUTDIR="./backup"
SRCDIR=""

# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        -dir) ROOT="$2"; shift 2 ;;
        -out) OUTDIR="$2"; shift 2 ;;
        -src) SRCDIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Set files to backup based on source directory
if [[ -n "$SRCDIR" ]]; then
    mapfile -t FILES_TO_BACKUP < <(find "$SRCDIR" -type f)
else
    FILES_TO_BACKUP=(
        "$ROOT/.bashrc"
        "$ROOT/.xinitrc"
        "$ROOT/.config/i3/config"
        "$ROOT/.config/picom.conf"
        "$ROOT/.config/kitty/kitty.conf"
        "$ROOT/.config/alacritty/alacritty.toml"
        "$ROOT/.config/starship.toml"
        "$ROOT/.config/nvim/init.lua"
        "$ROOT/.config/polybar/config.ini"
        "$ROOT/.local/bin/x"
        "/etc/default/grub"
        "$ROOT/.local/bin/startup.sh"
    )
fi

# Ensure output directory exists
mkdir -p "$OUTDIR"

# Function to generate backup filename
generate_backup_name() {
    local rel_path="$1"
    local backup_name=""
    
    IFS='/' read -ra path_parts <<< "$rel_path"
    
    # Add directory parts with {{}} wrapper
    for ((i=0; i<${#path_parts[@]}-1; i++)); do
        backup_name+="{{${path_parts[$i]}}}"
    done
    
    # Add filename with {} wrapper
    backup_name+="{${path_parts[${#path_parts[@]}-1]}}"
    echo "$backup_name"
}

# Process each file
for src in "${FILES_TO_BACKUP[@]}"; do
    if [[ -f "$src" ]]; then
        # Determine relative path
        if [[ -n "$SRCDIR" ]]; then
            rel_path="${src#$SRCDIR/}"
        else
            rel_path="${src#$ROOT/}"
        fi
        
        backup_name=$(generate_backup_name "$rel_path")
        cp "$src" "$OUTDIR/$backup_name"
        echo "Copied $src -> $OUTDIR/$backup_name"
    else
        echo "Warning: $src not found, skipping."
    fi
done
