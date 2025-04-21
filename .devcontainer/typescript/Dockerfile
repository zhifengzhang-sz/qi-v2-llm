# .devcontainer/typescript/Dockerfile
FROM node:23

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

# Set up Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure Oh My Zsh with plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

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
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> ~/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> ~/.zshrc

# Set working directory
WORKDIR /workspace

# Install TypeScript globally
RUN npm install -g typescript

# Copy package.json and install dependencies
COPY ../typescript-workspace/package.json ./
RUN npm install

# Copy the rest of the workspace files
COPY ../typescript-workspace ./

# Expose the port for the TypeScript application
EXPOSE 3000

# Set Zsh as default shell
ENV SHELL=/bin/zsh

# Default command
CMD ["zsh"]