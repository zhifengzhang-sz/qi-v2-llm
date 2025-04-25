# .devcontainer/typescript/Dockerfile
FROM node:23

# Create a non-root user with sudo access
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Install sudo first
RUN apt-get update && apt-get install -y sudo

# Create group and user with better error handling
RUN groupadd -g $USER_GID -o $USERNAME 2>/dev/null || echo "Group exists" && \
    useradd -u $USER_UID -g $USER_GID -s /bin/bash -m $USERNAME 2>/dev/null || \
    useradd -g $USER_GID -s /bin/bash -m $USERNAME 2>/dev/null || echo "User exists" && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Install Zsh and dependencies
RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    wget \
    fonts-powerline \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Create directories if they don't exist
RUN mkdir -p /etc/zsh/zshrc.d

# Set up Oh My Zsh for root first
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure zsh for the user (with verification)
RUN mkdir -p /home/$USERNAME/.oh-my-zsh && \
    cp -r /root/.oh-my-zsh/* /home/$USERNAME/.oh-my-zsh/ && \
    cp /root/.zshrc /home/$USERNAME/.zshrc && \
    sed -i 's/\/root\/.oh-my-zsh/\/home\/'"$USERNAME"'\/.oh-my-zsh/g' /home/$USERNAME/.zshrc && \
    # Verify user exists before chown
    id $USERNAME && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.oh-my-zsh && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.zshrc

# Configure Oh My Zsh with plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/$USERNAME/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)/' /home/$USERNAME/.zshrc

# Create auto-completion setup
RUN echo 'autoload -Uz compinit && compinit\n\
# Node/npm auto-completion \n\
if [ -f ~/.npm/packages/lib/node_modules/npm/lib/utils/completion.sh ]; then\n\
  source ~/.npm/packages/lib/node_modules/npm/lib/utils/completion.sh\n\
fi\n\
# Auto-completion for git\n\
if [ -f /usr/share/zsh/vendor-completions/_git ]; then\n\
  source /usr/share/zsh/vendor-completions/_git\n\
fi\n\
' > /etc/zsh/zshrc.d/auto-completion.zsh

# Create custom setup script
RUN echo '# Custom environment setup\n\
test-network() {\n\
  echo "Testing connectivity:"\n\
  echo -n "npm registry: " && curl -s -o /dev/null -w "%{http_code}" https://registry.npmjs.org || echo "Failed"\n\
}\n\
\n\
# Aliases\n\
alias ll="ls -la"\n\
' > /etc/zsh/zshrc.d/custom-setup.zsh

# Update .zshrc to source custom scripts
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /home/$USERNAME/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /home/$USERNAME/.zshrc

# Set working directory
WORKDIR /workspace/typescript-workspace

# Install TypeScript globally
RUN npm install -g typescript

# Expose the port for the TypeScript application
EXPOSE 3000

# Change ownership of npm cache and config
RUN mkdir -p /home/$USERNAME/.npm && chown -R $USERNAME:$USERNAME /home/$USERNAME/.npm

# Set Zsh as default shell
ENV SHELL=/bin/zsh

USER $USERNAME

# Default command
CMD ["zsh"]