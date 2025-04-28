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
    python3-full \
    git \
    curl \
    wget \
    zsh \
    fonts-powerline \
    bash-completion \
    python3-argcomplete \
    sudo \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Now pip commands will use the virtual environment
RUN pip config set global.timeout 120 && \
    pip install --upgrade pip setuptools wheel

# --- User Creation Section ---
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Install sudo first
RUN apt-get update && apt-get install -y sudo && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the group and user, add to sudoers with NOPASSWD
RUN groupadd -g ${USER_GID} -o ${USERNAME} 2>/dev/null || echo "Group ${USER_GID} already exists." && \
    useradd -u ${USER_UID} -g ${USER_GID} --shell /bin/zsh --create-home ${USERNAME} 2>/dev/null || \
    (usermod -l ${USERNAME} $(getent passwd ${USER_UID} | cut -d: -f1) && usermod -d /home/${USERNAME} -m ${USERNAME}) 2>/dev/null || \
    echo "User ${USERNAME} (UID ${USER_UID}) already exists or could not be fully configured." && \
    # Ensure sudoers directory exists and add NOPASSWD rule
    mkdir -p /etc/sudoers.d && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    # Verification steps
    echo "Verifying user ${USERNAME} (UID ${USER_UID}) exists..." && id ${USERNAME} && \
    echo "Verifying sudoers config for ${USERNAME}..." && cat /etc/sudoers.d/${USERNAME} && \
    echo "Testing sudo access for ${USERNAME}..." && sudo -u ${USERNAME} sudo -n true || echo "Sudo test failed for ${USERNAME}"
# --- End User Creation Section ---

# Set up Oh My Zsh for root
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Create directories if they don't exist
RUN mkdir -p /etc/zsh/zshrc.d

# Configure zsh for the user
RUN mkdir -p /home/$USERNAME/.oh-my-zsh && \
    cp -r /root/.oh-my-zsh/* /home/$USERNAME/.oh-my-zsh/ && \
    cp /root/.zshrc /home/$USERNAME/.zshrc && \
    sed -i 's/\/root\/.oh-my-zsh/\/home\/'"$USERNAME"'\/.oh-my-zsh/g' /home/$USERNAME/.zshrc && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.oh-my-zsh && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.zshrc

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
RUN echo '# Custom environment setup\n\
test-network() {\n\
  echo "Testing Docker registry connectivity:"\n\
  echo -n "Docker Hub: " && curl -s -o /dev/null -w "%{http_code}" https://registry-1.docker.io/v2/ || echo "Failed"\n\
  echo -n "PyPI: " && curl -s -o /dev/null -w "%{http_code}" https://pypi.org || echo "Failed"\n\
}\n\
\n\
# Automatically activate the virtual environment\n\
source /opt/venv/bin/activate\n\
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

# This line copies the file from .devcontainer/.zshrc into the container
COPY ../.zshrc /home/$USERNAME/.zshrc

# Change ownership of the virtual environment to the non-root user
RUN chown -R ${USERNAME}:${USERNAME} /opt/venv

# Set working directory
WORKDIR /workspace/python-workspace

# Set Zsh as the default shell
ENV SHELL=/bin/zsh

# Switch to non-root user
USER $USERNAME

# Default command
CMD ["zsh"]