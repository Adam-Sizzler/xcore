#!/bin/bash

DIR_REVERSE_PROXY="/usr/local/reverse_proxy/"
mkdir -p "${DIR_REVERSE_PROXY}repo/"

#REPO_URL="https://github.com/cortez24rus/reverse_proxy/archive/refs/heads/main.tar.gz"
TOKEN="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"
REPO_URL="https://api.github.com/repos/cortez24rus/reverse_proxy/tarball/main"

#wget -qO- $REPO_URL | tar xz --strip-components=1 -C "${DIR_REVERSE_PROXY}repo/"
wget --header="Authorization: Bearer $TOKEN" -qO- $REPO_URL | tar xz --strip-components=1 -C "${DIR_REVERSE_PROXY}repo/"

chmod +x "${DIR_REVERSE_PROXY}repo/reverse_proxy.sh"
ln -sf ${DIR_REVERSE_PROXY}repo/reverse_proxy.sh /usr/local/bin/reverse_proxy
#bash "${DIR_REVERSE_PROXY}repo/reverse_proxy.sh"
