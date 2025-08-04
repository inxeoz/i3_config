#!/bin/bash

# x: run command, show real-time output, save to file, copy output to clipboard at end

TMP_FILE=$(mktemp)
trap 'cat "$TMP_FILE" | xclip -selection clipboard; rm -f "$TMP_FILE"; echo -e "\n\n📋 Output copied to clipboard.";' EXIT

# Run the command and tee output to both terminal and temp file
"$@" 2>&1 | tee "$TMP_FILE"
