#!/bin/bash

TARGET_DIR="/usr/local/reverse_proxy/bin"
mkdir -p "$TARGET_DIR"

git clone https://github.com/cortez24rus/reverse_proxy.git "$TARGET_DIR"
chmod +x "$TARGET_DIR/reverse_proxy.sh"

bash "$TARGET_DIR/reverse_proxy.sh"