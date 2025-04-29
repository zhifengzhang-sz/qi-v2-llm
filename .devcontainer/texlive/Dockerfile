FROM texlive/texlive:latest

# Install Zsh and dependencies
RUN apt-get update && apt-get install -y \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-science \
    zsh \
    git \
    curl \
    wget \
    fonts-powerline \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with sudo access - SIMPLIFIED VERSION
# Update just the user creation section
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Fix typo in id command and improve error handling
RUN groupadd -g $USER_GID -o $USERNAME 2>/dev/null || echo "Group exists" && \
    useradd -u $USER_UID -g $USER_GID -s /bin/bash -m $USERNAME 2>/dev/null || \
    useradd -g $USER_GID -s /bin/bash -m $USERNAME 2>/dev/null || echo "User exists" && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    id $USERNAME || echo "Warning: User verification failed"

# Create directories if they don't exist
RUN mkdir -p /etc/zsh/zshrc.d

# Set up Oh My Zsh for root
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure zsh for the user
RUN mkdir -p /home/$USERNAME/.oh-my-zsh && \
    cp -r /root/.oh-my-zsh/* /home/$USERNAME/.oh-my-zsh/ && \
    cp /root/.zshrc /home/$USERNAME/.zshrc && \
    sed -i 's/\/root\/.oh-my-zsh/\/home\/'"$USERNAME"'\/.oh-my-zsh/g' /home/$USERNAME/.zshrc && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.oh-my-zsh && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.zshrc

# Create auto-completion setup
RUN echo 'autoload -Uz compinit && compinit\n\
# Auto-completion for git\n\
if [ -f /usr/share/zsh/vendor-completions/_git ]; then\n\
  source /usr/share/zsh/vendor-completions/_git\n\
fi\n\
' > /etc/zsh/zshrc.d/auto-completion.zsh

# Create custom setup script
RUN echo '# Custom environment setup\n\
test-network() {\n\
  echo "Testing connectivity:"\n\
  echo -n "CTAN: " && curl -s -o /dev/null -w "%{http_code}" https://ctan.org || echo "Failed"\n\
}\n\
\n\
# Aliases\n\
alias ll="ls -la"\n\
alias latexmk="latexmk -pdf -interaction=nonstopmode"\n\
' > /etc/zsh/zshrc.d/custom-setup.zsh

# Update .zshrc to source custom scripts
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /home/$USERNAME/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /home/$USERNAME/.zshrc

# Copy custom .zshrc file
COPY ../.zshrc /home/$USERNAME/.zshrc

# Set working directory
#WORKDIR /workspace

# Set Zsh as default shell
ENV SHELL=/bin/zsh

# Default command
USER $USERNAME
CMD ["zsh"]