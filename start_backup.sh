#!/bin/bash
# start_backup.sh - Copy config files from home to current folder, renaming dotfiles for git tracking

# List of files to backup (add or remove as needed)
FILES_TO_BACKUP=(
    "$HOME/.bashrc"
    "$HOME/.xinitrc"
    "$HOME/.config/i3/config"
    "$HOME/.config/picom/picom.conf"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/alacritty/alacritty.toml"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim/init.lua",
    "$HOME/.config/polybar/config.ini",
    "$HOME/.local/bin/x",
     

)



# Ensure backup directory exists
mkdir -p ./backup



for src in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$src" ]; then
        # Remove $HOME/ from the path
        rel_path="${src#$HOME/}"
        IFS='/' read -ra path_parts <<< "$rel_path"
        backup_name=""
        for ((i=0; i<${#path_parts[@]}-1; i++)); do
            backup_name+="{{${path_parts[$i]}}}"
        done
    file_name="${path_parts[${#path_parts[@]}-1]}"
    backup_name+="{${file_name}}"
        cp "$src" "./backup/$backup_name"
        echo "Copied $src -> backup/$backup_name"
    else
        echo "Warning: $src not found, skipping."
    fi
done

# Default root directory is $HOME, default output is ./backup, default src is empty
ROOT="$HOME"
OUTDIR="./backup"
SRCDIR=""
# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        -dir)
            shift
            ROOT="$1"
            ;;
        -out)
            shift
            OUTDIR="$1"
            ;;
        -src)
            shift
            SRCDIR="$1"
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# List of files to backup (add or remove as needed)
if [[ -n "$SRCDIR" ]]; then
    # Find all files under SRCDIR
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
    )
fi

# Ensure output directory exists
mkdir -p "$OUTDIR"

for src in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$src" ]; then
        # Remove $ROOT/ or $SRCDIR/ from the path
        if [[ -n "$SRCDIR" ]]; then
            rel_path="${src#$SRCDIR/}"
        else
            rel_path="${src#$ROOT/}"
        fi
        IFS='/' read -ra path_parts <<< "$rel_path"
        backup_name=""
        for ((i=0; i<${#path_parts[@]}-1; i++)); do
            backup_name+="{{${path_parts[$i]}}}"
        done
        file_name="${path_parts[${#path_parts[@]}-1]}"
        backup_name+="{${file_name}}"
        cp "$src" "$OUTDIR/$backup_name"
        echo "Copied $src -> $OUTDIR/$backup_name"
    else
        echo "Warning: $src not found, skipping."
    fi
done
