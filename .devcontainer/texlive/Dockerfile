FROM docker.io/texlive/texlive:latest

# Install necessary tools
RUN apt-get update && apt-get install -y \
    tree \
    curl \
    git \
    wget \
    less \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set up arguments for username and UID/GID
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Handle the case where the texlive user exists - rename it to the new USERNAME
RUN if getent passwd texlive > /dev/null; then \
    usermod -l $USERNAME texlive && \
    usermod -d /home/$USERNAME -m $USERNAME && \
    groupmod -n $USERNAME texlive && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME; \
else \
    # If texlive user doesn't exist, create the new user
    groupadd -g $USER_GID -o $USERNAME 2>/dev/null || groupmod -g $USER_GID $USERNAME && \
    useradd -u $USER_UID -g $USER_GID -s /bin/zsh -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME; \
fi

# Additional setup for ZSH
RUN mkdir -p /etc/zsh/zshrc.d
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Copy the zshrc file to the user's home directory
RUN mkdir -p /home/$USERNAME/.oh-my-zsh && \
    cp -r /root/.oh-my-zsh/templates/zshrc.zsh-template /home/$USERNAME/.zshrc

# Add custom scripts and configurations
RUN echo 'autoload -Uz compinit && compinit\ninclude /etc/zsh/zshrc.d/*.zsh 2> /dev/null' > /etc/zsh/zshrc.d/auto-completion.zsh
RUN echo '# Custom environment setup\ntest-network() {\n  ping -c 1 google.com\n}' > /etc/zsh/zshrc.d/custom-setup.zsh
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /home/$USERNAME/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /home/$USERNAME/.zshrc

# Copy the .zshrc file if it exists in the build context
COPY ./.zshrc /home/$USERNAME/.zshrc

# Make sure all files in the home directory are owned by the user
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set the default user
USER $USERNAME
WORKDIR /home/$USERNAME

CMD ["zsh"]