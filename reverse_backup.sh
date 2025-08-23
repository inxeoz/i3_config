#!/bin/bash
# reverse_backup.sh - Restore config files from dot-joined backup names in current folder to their original locations

# Default values
ROOT="$HOME"
SRCDIR="./backup"
OUTDIR=""

# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        -dir) ROOT="$2"; shift 2 ;;
        -src) SRCDIR="$2"; shift 2 ;;
        -out) OUTDIR="$2"; shift 2 ;;
        --demo) ROOT="./reverse_backup"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Function to decode backup filename to original path
decode_backup_name() {
    local fname="$1"
    local path_rebuild=""
    local rest="$fname"
    
    # Extract folder parts wrapped in {{}}
    while [[ "$rest" =~ ^\{\{([^}]*)\}\}(.*) ]]; do
        path_rebuild+="${BASH_REMATCH[1]}/"
        rest="${BASH_REMATCH[2]}"
    done
    
    # Extract filename wrapped in {}
    if [[ "$rest" =~ ^\{([^}]*)\}$ ]]; then
        path_rebuild+="${BASH_REMATCH[1]}"
    else
        # Fallback: use rest as-is
        path_rebuild+="$rest"
    fi
    
    echo "$path_rebuild"
}

# Process each backup file
for file in "$SRCDIR"/*; do
    [[ -f "$file" ]] || continue
    
    fname="$(basename "$file")"
    path_rebuild=$(decode_backup_name "$fname")
    
    # Determine destination
    dest="${OUTDIR:-$ROOT}/$path_rebuild"
    
    # Create destination directory and copy file
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
    echo "Restored $fname -> $dest"
done