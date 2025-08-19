#!/bin/bash
# start_backup.sh - Copy config files from home to current folder, renaming dotfiles for git tracking

# List of files to backup (add or remove as needed)
FILES_TO_BACKUP=(
    "$HOME/.bashrc"
    "$HOME/.xinitrc"
    "$HOME/.config/i3/config"
    "$HOME/.config/picom.conf"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/alacritty/alacritty.toml"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim/init.lua",
    "$HOME/.config/polybar/config.ini",

)



# Ensure backup directory exists
mkdir -p ./backup

for src in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$src" ]; then
        # Remove $HOME/ from the path
        rel_path="${src#$HOME/}"
        # Replace all / with .
        dot_path="${rel_path//\//.}"
        orig_file_name="$(basename "$src")"
        if [[ "$orig_file_name" == .* ]]; then
            # If file name starts with a dot, replace with {DOT}
            # Find the path before the file name
            path_before_file="${dot_path%.*}"
            file_name="{DOT}${orig_file_name#.}"
            if [[ -n "$path_before_file" && "$path_before_file" != "$dot_path" ]]; then
                newname="${path_before_file}.$file_name"
            else
                newname="$file_name"
            fi
        else
            # Normal process: just use dot_path
            newname="$dot_path"
        fi
        cp "$src" "./backup/$newname"
        echo "Copied $src -> backup/$newname"
    else
        echo "Warning: $src not found, skipping."
    fi
done
