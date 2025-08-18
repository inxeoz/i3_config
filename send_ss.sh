#!/bin/bash
REMOTE_USER="inxeoz"
REMOTE_IP="192.168.10.2"
REMOTE_DIR="/home/inxeoz/.Shareable"

scp ~/.Shareable/inxeozss.png "$REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/"
