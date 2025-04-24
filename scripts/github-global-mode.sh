#!/bin/bash

# Reset Git to use direct GitHub URLs
git config --global --unset url."https://ghproxy.com/https://github.com/".insteadOf
git config --global --unset url."https://gitclone.com/github.com/".insteadOf

# Reset npm to default registry
npm config delete registry

# Reset pip to default
pip config unset global.index-url

echo "GitHub, npm and pip reset to global mode."
