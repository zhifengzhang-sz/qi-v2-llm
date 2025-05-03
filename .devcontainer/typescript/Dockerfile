# .devcontainer/typescript/Dockerfile
FROM node:23

# Create a non-root user with sudo access
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Install sudo and other tools
RUN apt-get update && apt-get install -y sudo zsh git curl wget fonts-powerline bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Handle the existing "node" user - either rename it or create a new user
RUN if getent passwd node > /dev/null; then \
    # If node user exists, rename it
    usermod -l $USERNAME node && \
    usermod -d /home/$USERNAME -m $USERNAME && \
    groupmod -n $USERNAME node && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME; \
else \
    # If node user doesn't exist, create our user
    groupadd -g $USER_GID -o $USERNAME 2>/dev/null || groupmod -g $USER_GID $USERNAME && \
    useradd -u $USER_UID -g $USER_GID -s /bin/zsh -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME; \
fi

# Create zsh configuration directories
RUN mkdir -p /etc/zsh/zshrc.d

# Set up Oh My Zsh for root
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure zsh for the user
RUN mkdir -p /home/$USERNAME/.oh-my-zsh && \
    cp -r /root/.oh-my-zsh/* /home/$USERNAME/.oh-my-zsh/ && \
    cp /root/.zshrc /home/$USERNAME/.zshrc && \
    sed -i 's/\/root\/.oh-my-zsh/\/home\/'"$USERNAME"'\/.oh-my-zsh/g' /home/$USERNAME/.zshrc

# Configure Oh My Zsh theme and plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/$USERNAME/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm)/' /home/$USERNAME/.zshrc

# Create auto-completion setup
RUN echo 'autoload -Uz compinit && compinit\n# Node/npm auto-completion' > /etc/zsh/zshrc.d/auto-completion.zsh

# Create custom setup script
RUN echo '# Custom environment setup\ntest-network() {\n  echo "Testing connectivity:"\n  ping -c 1 google.com\n}' > /etc/zsh/zshrc.d/custom-setup.zsh

# Update .zshrc to source custom scripts
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /home/$USERNAME/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /home/$USERNAME/.zshrc

# Copy custom .zshrc file (path relative to context)
COPY ./.zshrc /home/$USERNAME/.zshrc

# Install TypeScript globally
RUN npm install -g typescript

# Ensure proper ownership
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set the default user
USER $USERNAME
ENV SHELL=/bin/zsh

# Default command
CMD ["zsh"]