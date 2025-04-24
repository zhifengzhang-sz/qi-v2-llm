#!/bin/bash

# Configure Git to use mirrors for GitHub
git config --global url."https://ghproxy.com/https://github.com/".insteadOf "https://github.com/"
git config --global url."https://gitclone.com/github.com/".insteadOf "git@github.com:"

# Configure npm to use mirrors for GitHub packages
npm config set registry https://registry.npmmirror.com

# Configure pip to use mirrors
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/

echo "GitHub, npm and pip configured for China mode."
