# .devcontainer/typescript/Dockerfile
FROM node:23

# Create a non-root user matching host user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

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

# Set up Oh My Zsh for the user
RUN su $USERNAME -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' && \
    su $USERNAME -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions' && \
    su $USERNAME -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

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