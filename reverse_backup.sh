#!/bin/bash
# reverse_backup.sh - Restore config files from dot-joined backup names in current folder to their original locations


for file in ./backup/*; do
    # Skip directories
    [ -f "$file" ] || continue
    fname="$(basename "$file")"
    # Decode {DOT} to . in the file name part
    IFS='.' read -ra parts <<< "$fname"
    for i in "${!parts[@]}"; do
        if [[ "${parts[$i]}" == "{DOT}"* ]]; then
            parts[$i]=".${parts[$i]#\{DOT\}}"
        fi
    done
    rel_path="${parts[0]}"
    for ((i=1; i<${#parts[@]}; i++)); do
        rel_path+="/${parts[$i]}"
    done
    dest="$HOME/$rel_path"
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"
    cp "$file" "$dest"
    echo "Restored $fname -> $dest"
