# Docker Ecosystem: Windows 11 Pro + WSL Ubuntu 24.04

## 1. Docker Ecosystem Topology

Here's how Docker works across Windows 11 and WSL:

```
┌─────────────────────────────────────────┐
│             Windows 11 Pro              │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │        Docker Desktop           │    │
│  │                                 │    │
│  │  ┌─────────┐    ┌────────────┐  │    │
│  │  │ Docker  │    │   Docker   │  │    │
│  │  │ Engine  │◄───┤   CLI      │  │    │
│  │  └─────────┘    └────────────┘  │    │
│  │       ▲                         │    │
│  └───────┼─────────────────────────┘    │
│          │                              │
└──────────┼──────────────────────────────┘
           │
┌──────────┼──────────────────────────────┐
│          │      WSL 2                   │
│          │                              │
│  ┌───────▼──────────┐                   │
│  │  /var/run/       │   ┌────────────┐  │
│  │  docker.sock     │◄──┤   Docker   │  │
│  │  (WSL socket)    │   │   CLI      │  │
│  └──────────────────┘   └────────────┘  │
│                                         │
│         Ubuntu 24.04                    │
└─────────────────────────────────────────┘
```

### Key Points:

1. **Single Docker Engine**: Only one Docker Engine runs (in Docker Desktop)
2. **Shared Socket**: The Docker socket in WSL connects to Windows Docker Engine
3. **Shared Resources**: Images and containers are accessible from both Windows and WSL
4. **Integration**: WSL integration must be enabled in Docker Desktop settings

## 2. Upgrading Docker in Ubuntu 24.04

When using WSL integration, you don't need to upgrade Docker in Ubuntu separately:

- **Docker Engine**: Upgrade by updating Docker Desktop on Windows
- **Docker CLI**: Usually provided by Docker Desktop WSL integration

If you prefer to install Docker CLI separately in WSL:

```bash
# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker CLI only (not engine)
sudo apt-get update
sudo apt-get install -y docker-ce-cli
```

## 3. Docker Compose and Docker

### Two Docker Compose Versions:

1. **Docker Compose V1**: 
   - Standalone binary: `docker-compose` command
   - Legacy version
   - Installed separately

2. **Docker Compose V2**:
   - Plugin for Docker: `docker compose` command (with space)
   - Current recommended version
   - Usually included with Docker Desktop

### Why You Don't Have Docker Compose in WSL:

The issue occurs because:

1. Docker Desktop's WSL integration provides Docker Engine access but sometimes doesn't properly set up Compose V2 plugin in WSL
2. Docker Compose V1 isn't installed by default in Ubuntu 24.04

### Solutions:

**Option A: Install Docker Compose V1 in WSL**
```bash
# Install Docker Compose V1
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify
docker-compose --version
```

**Option B: Install Docker Compose V2 Plugin in WSL**
```bash
# Create Docker CLI plugins directory
mkdir -p ~/.docker/cli-plugins/

# Download Docker Compose V2 plugin
curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

# Make it executable
chmod +x ~/.docker/cli-plugins/docker-compose

# Verify
docker compose version
```

## Add This to Your README.md:

```markdown
### WSL 2 Docker Configuration

For Windows 11 + WSL 2 users:

1. **Docker Desktop WSL Integration**:
   - Docker Desktop on Windows provides the Docker Engine
   - WSL uses this engine through integration
   - No separate Docker installation needed in Ubuntu

2. **Installing Docker Compose in WSL**:
   ```bash
   # Create Docker CLI plugins directory
   mkdir -p ~/.docker/cli-plugins/
   
   # Download Docker Compose plugin
   curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
   
   # Make it executable
   chmod +x ~/.docker/cli-plugins/docker-compose
   
   # Verify
   docker compose version
   ```

3. **Troubleshooting**:
   - If Docker works but Docker Compose doesn't, follow the installation steps above
   - If neither works, check Docker Desktop WSL integration settings
   - For permission issues: `sudo chmod 666 /var/run/docker.sock`
```

This setup ensures you can use Docker and Docker Compose in your WSL environment without needing to install a separate Docker Engine in Ubuntu.
