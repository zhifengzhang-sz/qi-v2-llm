FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Python, dependencies, and zsh
RUN apt-get update || \
    (echo "Failed with default sources, trying mirrors..." && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update) && \
    apt-get install -y \
    python3.10 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    zsh \
    fonts-powerline \
    bash-completion \
    python3-argcomplete \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Configure pip with global and fallback index
RUN pip config set global.timeout 120 && \
    pip install --upgrade pip

# Create a non-root user with sudo access
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up Oh My Zsh for both root and non-root user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && su $USERNAME -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Install additional Oh My Zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && su $USERNAME -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions' \
    && su $USERNAME -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

# Configure Oh My Zsh with plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/$USERNAME/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git python pip docker virtualenv zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git python pip docker virtualenv zsh-autosuggestions zsh-syntax-highlighting)/' /home/$USERNAME/.zshrc

# Add auto-completion for common tools
RUN echo 'autoload -Uz compinit && compinit\n\
# Auto-completion for pip\n\
eval "$(pip completion --zsh)"\n\
# Auto-completion for docker\n\
if [ -f /usr/share/zsh/vendor-completions/_docker ]; then\n\
  source /usr/share/zsh/vendor-completions/_docker\n\
fi\n\
# Auto-completion for git\n\
if [ -f /usr/share/zsh/vendor-completions/_git ]; then\n\
  source /usr/share/zsh/vendor-completions/_git\n\
fi\n\
# Python argcomplete\n\
if command -v register-python-argcomplete > /dev/null; then\n\
  eval "$(register-python-argcomplete --shell zsh python)"\n\
fi\n\
' > /etc/zsh/zshrc.d/auto-completion.zsh

# Create Zsh setup script to source in .zshrc
RUN mkdir -p /etc/zsh/zshrc.d && echo '# Custom environment setup\n\
test-network() {\n\
  echo "Testing Docker registry connectivity:"\n\
  echo -n "Docker Hub: " && curl -s -o /dev/null -w "%{http_code}" https://registry-1.docker.io/v2/ || echo "Failed"\n\
  echo -n "PyPI: " && curl -s -o /dev/null -w "%{http_code}" https://pypi.org || echo "Failed"\n\
}\n\
\n\
# Aliases\n\
alias ll="ls -la"\n\
alias python="python3"\n\
alias pip="pip3"\n\
' > /etc/zsh/zshrc.d/custom-setup.zsh

# Update both root and user .zshrc files to source the setup script
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /root/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /home/$USERNAME/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /root/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /home/$USERNAME/.zshrc

# Set working directory
WORKDIR /workspace/python-workspace

# Set Zsh as the default shell
SHELL ["/bin/zsh", "-c"]
USER $USERNAME
ENV SHELL=/bin/zsh

# Default command
CMD ["zsh"]