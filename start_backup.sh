#!/bin/bash
# start_backup.sh - Copy config files from home (or custom dir) to backup folder
# Dotfiles and nested paths are renamed with { } for git tracking.

set -euo pipefail

# Defaults
ROOT="$HOME"
OUTDIR="./backup"
SRCDIR=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -dir)  ROOT="$2"; shift 2 ;;
        -out)  OUTDIR="$2"; shift 2 ;;
        -src)  SRCDIR="$2"; shift 2 ;;
        *)     echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Determine files to backup
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
    )
fi

# Ensure output directory exists
mkdir -p "$OUTDIR"

# Copy files with transformed names
for src in "${FILES_TO_BACKUP[@]}"; do
    if [[ -f "$src" ]]; then
        # Relative path stripping
        if [[ -n "$SRCDIR" ]]; then
            rel_path="${src#$SRCDIR/}"
        else
            rel_path="${src#$ROOT/}"
        fi

        # Replace path separators with { } for Git tracking
        IFS='/' read -ra path_parts <<< "$rel_path"
        backup_name=""
        for ((i=0; i<${#path_parts[@]}-1; i++)); do
            backup_name+="{${path_parts[$i]}}"
        done
        file_name="${path_parts[-1]}"
        backup_name+="{${file_name}}"

        cp "$src" "$OUTDIR/$backup_name"
        echo "Copied: $src -> $OUTDIR/$backup_name"
    else
        echo "Warning: $src not found, skipping." >&2
    fi
done
