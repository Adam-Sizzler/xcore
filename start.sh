#!/bin/bash

DIR_XCORE_PROXY="/opt/xcore"
mkdir -p "${DIR_XCORE_PROXY}/repo/"

TOKEN="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"
REPO_URL="https://api.github.com/repos/cortez24rus/XCore/tarball/main"

wget --header="Authorization: Bearer $TOKEN" -qO- $REPO_URL | tar xz --strip-components=1 -C "${DIR_XCORE_PROXY}/repo/"

chmod +x "${DIR_XCORE_PROXY}/repo/xcore.sh"
ln -sf ${DIR_XCORE_PROXY}/repo/xcore.sh /usr/local/bin/xcore