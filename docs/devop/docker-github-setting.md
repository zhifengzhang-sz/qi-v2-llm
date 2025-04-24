# Docker & GitHub Configuration for Network Restrictions

I see you're having network connectivity issues (couldn't resolve github.com). Let's improve your setup by:

1. Moving shell scripts into your project
2. Adding GitHub mirror configuration for restrictive networks

## 1. Moving Docker Scripts to Project

Create a `scripts` directory and move the Docker configuration scripts there:

```bash
# Create directory
mkdir -p scripts

# Create docker mode scripts in project directory
cat > scripts/docker-china-mode.sh << 'EOF'
#!/bin/bash

echo '{
  "registry-mirrors": [
    "https://registry.docker-cn.com/",
    "https://hub-mirror.c.163.com/",
    "https://mirror.baidubce.com/"
  ]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for China mode. Docker service restarted."
EOF

cat > scripts/docker-global-mode.sh << 'EOF'
#!/bin/bash

echo '{
  "registry-mirrors": []
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for global mode. Docker service restarted."
EOF

# Make them executable
chmod +x scripts/docker-china-mode.sh scripts/docker-global-mode.sh
```

---

## 2. Adding GitHub Mirror Configuration

Create scripts for GitHub mirror configuration:

```bash
# Create GitHub configuration scripts
cat > scripts/github-china-mode.sh << 'EOF'
#!/bin/bash

# Configure Git to use mirrors for GitHub
git config --global url."https://ghproxy.com/https://github.com/".insteadOf "https://github.com/"
git config --global url."https://gitclone.com/github.com/".insteadOf "git@github.com:"

# Configure npm to use mirrors for GitHub packages
npm config set registry https://registry.npmmirror.com

# Configure pip to use mirrors
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/

echo "GitHub, npm and pip configured for China mode."
EOF

cat > scripts/github-global-mode.sh << 'EOF'
#!/bin/bash

# Reset Git to use direct GitHub URLs
git config --global --unset url."https://ghproxy.com/https://github.com/".insteadOf
git config --global --unset url."https://gitclone.com/github.com/".insteadOf

# Reset npm to default registry
npm config delete registry

# Reset pip to default
pip config unset global.index-url

echo "GitHub, npm and pip reset to global mode."
EOF

# Make them executable
chmod +x scripts/github-china-mode.sh scripts/github-global-mode.sh
```

---

## 3. Update [`package.json`](package.json )

```json
{
  "name": "multi-language-dev-containers",
  "version": "1.0.0",
  "description": "Multi-language development environment with VS Code DevContainers",
  "scripts": {
    "setup": "chmod +x .devcontainer/setup.sh && ./.devcontainer/setup.sh",
    "docker:china": "chmod +x scripts/docker-china-mode.sh && ./scripts/docker-china-mode.sh",
    "docker:global": "chmod +x scripts/docker-global-mode.sh && ./scripts/docker-global-mode.sh",
    "github:china": "chmod +x scripts/github-china-mode.sh && ./scripts/github-china-mode.sh",
    "github:global": "chmod +x scripts/github-global-mode.sh && ./scripts/github-global-mode.sh",
    "network:china": "npm run docker:china && npm run github:china",
    "network:global": "npm run docker:global && npm run github:global",
    "build": "cd .devcontainer && (docker compose build || docker-compose build)",
    "start": "cd .devcontainer && (docker compose up -d || docker-compose up -d)",
    "stop": "cd .devcontainer && (docker compose down || docker-compose down)",
    "compose:install": "./scripts/install-compose.sh",
    "python": "cd .devcontainer && (docker compose run --rm python zsh || docker-compose run --rm python zsh)",
    "typescript": "cd .devcontainer && (docker compose run --rm typescript zsh || docker-compose run --rm typescript zsh)",
    "texlive": "cd .devcontainer && (docker compose run --rm texlive zsh || docker-compose run --rm texlive zsh)"
  }
}
```

---

## 4. Local Docker Compose Installation Script

Create a script to install Docker Compose locally:

```bash
# Create Docker Compose installation script
cat > scripts/install-compose.sh << 'EOF'
#!/bin/bash

echo "Installing Docker Compose..."

# For China networks, try mirrors first
if ping -c 1 -W 2 ghproxy.com &> /dev/null; then
  echo "Using China mirror for Docker Compose..."
  COMPOSE_URL="https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64"
else
  echo "Using direct GitHub URL..."
  COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64"
fi

# Create Docker CLI plugins directory
mkdir -p ~/.docker/cli-plugins/

# Try to download with progress
echo "Downloading from: $COMPOSE_URL"
if ! curl -SL --progress-bar "$COMPOSE_URL" -o ~/.docker/cli-plugins/docker-compose; then
  echo "Failed to download Docker Compose."
  echo "Error: Network connectivity issue. You may need to configure network settings."
  exit 1
fi

# Make executable
chmod +x ~/.docker/cli-plugins/docker-compose

# Create symlink for backward compatibility
echo "Creating symlink to /usr/local/bin/docker-compose..."
sudo ln -sf ~/.docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Verify installation
echo "Verifying installation..."
if docker compose version; then
  echo "Docker Compose V2 installed successfully."
elif docker-compose --version; then
  echo "Docker Compose installed successfully (V1 compatibility)."
else
  echo "Docker Compose installation seems to have failed. Please check errors above."
  exit 1
fi
EOF

# Make it executable
chmod +x scripts/install-compose.sh
```

---

## 5. Update the Docker WSL Documentation

### Configuring for Network Restrictions

For users in regions with network restrictions, this project includes scripts to configure Docker and GitHub:

1. **Switch to China-friendly mirrors**:
   ```bash
   # Configure both Docker and GitHub for China networks
   npm run network:china
   
   # Or configure them separately
   npm run docker:china
   npm run github:china
   ```

2. **Switch back to global settings**:
   ```bash
   npm run network:global
   ```

3. **Install Docker Compose locally**:
   If Docker Compose isn't available through Docker Desktop WSL integration:
   ```bash
   npm run compose:install
   ```

These scripts automatically detect and use the best mirrors for your network conditions.

---

This comprehensive setup provides:
1. ✅ Localized Docker scripts within your project
2. ✅ Similar configuration for GitHub and package managers
3. ✅ Network-aware Docker Compose installation
4. ✅ Simplified npm commands for easy switching between modes
5. ✅ Support for both Docker Compose V1 and V2 syntax

These changes will make your development environment much more resilient when working across different network environments.