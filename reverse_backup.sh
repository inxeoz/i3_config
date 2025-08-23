#!/bin/bash
# reverse_backup.sh - Restore config files from { }-encoded backup names
# Converts names like {config}{nvim}{init.lua} back into ~/.config/nvim/init.lua

set -euo pipefail

# Defaults
ROOT="$HOME"
SRCDIR="./backup"
OUTDIR=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -dir)  ROOT="$2"; shift 2 ;;
        -src)  SRCDIR="$2"; shift 2 ;;
        -out)  OUTDIR="$2"; shift 2 ;;
        --demo) ROOT="./reverse_backup"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Ensure source exists
if [[ ! -d "$SRCDIR" ]]; then
    echo "Error: Source directory '$SRCDIR' does not exist." >&2
    exit 1
fi

# Process each file in backup dir
shopt -s nullglob
for file in "$SRCDIR"/*; do
    [[ -f "$file" ]] || continue
    fname="$(basename "$file")"

    # Decode backup name:
    # {config}{nvim}{init.lua} → config/nvim/init.lua
    path_rebuild="${fname//\}/}"   # strip braces safely
    path_rebuild="${path_rebuild//\}\{//}"  # replace '}{' with '/'
    path_rebuild="${path_rebuild#\{}"       # strip leading {
    path_rebuild="${path_rebuild%\}}"       # strip trailing }

    # Destination: OUTDIR > ROOT
    if [[ -n "$OUTDIR" ]]; then
        dest="$OUTDIR/$path_rebuild"
    else
        dest="$ROOT/$path_rebuild"
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
    echo "Restored: $fname -> $dest"
done
