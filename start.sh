#!/bin/bash

REPO_URL="https://github.com/cortez24rus/reverse_proxy.git"
DIR_REVERSE_PROXY="/usr/local/reverse_proxy/"

mkdir -p "${DIR_REVERSE_PROXY}repo/"
git clone $REPO_URL "${DIR_REVERSE_PROXY}repo/"

chmod +x "${DIR_REVERSE_PROXY}repo/reverse_proxy.sh"
ln -sf ${DIR_REVERSE_PROXY}repo/reverse_proxy.sh /usr/local/bin/reverse_proxy