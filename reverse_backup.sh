#!/bin/bash
# reverse_backup.sh - Restore config files from dot-joined backup names in current folder to their original locations




# Default root directory is $HOME, default src is ./backup, default out is empty
ROOT="$HOME"
SRCDIR="./backup"
OUTDIR=""
# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        -dir)
            shift
            ROOT="$1"
            ;;
        -src)
            shift
            SRCDIR="$1"
            ;;
        -out)
            shift
            OUTDIR="$1"
            ;;
        --demo)
            ROOT="./reverse_backup"
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done


for file in "$SRCDIR"/*; do
    # Skip directories
    [ -f "$file" ] || continue
    fname="$(basename "$file")"
    # Decode backup name: {{folder}}{{folder}}{file}
    path_rebuild=""
    rest="$fname"
    while [[ "$rest" =~ ^\{\{([^}]*)\}\}(.*) ]]; do
        folder="${BASH_REMATCH[1]}"
        path_rebuild+="$folder/"
        rest="${BASH_REMATCH[2]}"
    done
    if [[ "$rest" =~ ^\{([^}]*)\}$ ]]; then
        file_name="${BASH_REMATCH[1]}"
        path_rebuild+="$file_name"
    else
        # fallback: just use rest
        path_rebuild+="$rest"
    fi
    if [[ -n "$OUTDIR" ]]; then
        dest="$OUTDIR/$path_rebuild"
    else
        dest="$ROOT/$path_rebuild"
    fi
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"
    cp "$file" "$dest"
    echo "Restored $fname -> $dest"

done