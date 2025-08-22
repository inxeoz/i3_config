#!/bin/bash
# update-mirrors.sh
# Updates Arch Linux mirrorlist to the fastest available mirrors

set -e

echo "Backing up current mirrorlist..."
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

echo "Updating mirrorlist to the fastest mirrors..."
sudo pacman-mirrors --fasttrack 10

echo "Refreshing package database..."
sudo pacman -Syy

echo "Mirrorlist update complete!"
