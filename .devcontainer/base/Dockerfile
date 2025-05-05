# Base image for all development containers
FROM ubuntu:24.10

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install common dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    zsh \
    git \
    curl \
    wget \
    less \
    fonts-powerline \
    bash-completion \
    tree \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# User & permission setup
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Create the user and setup sudo access with better handling of existing UIDs
RUN if getent passwd ${USER_UID} > /dev/null; then \
        # If the UID already exists, get the existing username
        existing_username=$(getent passwd ${USER_UID} | cut -d: -f1) && \
        # Update the username if different from our target
        if [ "$existing_username" != "$USERNAME" ]; then \
            usermod -l ${USERNAME} ${existing_username} && \
            groupmod -n ${USERNAME} ${existing_username} 2>/dev/null || true && \
            usermod -d /home/${USERNAME} -m ${USERNAME} 2>/dev/null || true; \
        fi; \
    else \
        # If the UID doesn't exist, create the user normally
        groupadd -g ${USER_GID} -o ${USERNAME} 2>/dev/null || true && \
        useradd -u ${USER_UID} -g ${USER_GID} -s /bin/zsh -m ${USERNAME}; \
    fi && \
    # Ensure the user has sudo access in any case
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Set up Oh My Zsh for root
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set up Oh My Zsh for the user with proper permissions
RUN mkdir -p /home/${USERNAME}/.oh-my-zsh && \
    cp -r /root/.oh-my-zsh/* /home/${USERNAME}/.oh-my-zsh/ && \
    cp /root/.zshrc /home/${USERNAME}/.zshrc && \
    sed -i 's/\/root\/.oh-my-zsh/\/home\/'"${USERNAME}"'\/.oh-my-zsh/g' /home/${USERNAME}/.zshrc && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.oh-my-zsh && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.zshrc

# Create the custom plugins directory with proper ownership
RUN mkdir -p /home/${USERNAME}/.oh-my-zsh/custom/plugins && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.oh-my-zsh/custom

# Install Oh My Zsh plugins for root
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install Oh My Zsh plugins for the user
RUN su ${USERNAME} -c "git clone https://github.com/zsh-users/zsh-autosuggestions /home/${USERNAME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" && \
    su ${USERNAME} -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/${USERNAME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# Configure ZSH theme and plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="gnzh"/' /root/.zshrc && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="gnzh"/' /home/$USERNAME/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /home/$USERNAME/.zshrc

# Create shared ZSH configuration directories and files
RUN mkdir -p /etc/zsh/zshrc.d
RUN echo 'autoload -Uz compinit && compinit' > /etc/zsh/zshrc.d/auto-completion.zsh
RUN echo '# Custom utilities\n\
test-network() {\n\
  echo "Testing connectivity:"\n\
  echo -n "GitHub: " && curl -s -o /dev/null -w "%{http_code}" https://github.com || echo "Failed"\n\
  echo -n "Docker Hub: " && curl -s -o /dev/null -w "%{http_code}" https://registry-1.docker.io/v2/ || echo "Failed"\n\
}\n\n\
# Aliases\n\
alias ll="ls -la"\n\
' > /etc/zsh/zshrc.d/custom-setup.zsh

# Update both root and user .zshrc files to source the setup scripts
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> /home/$USERNAME/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> /home/$USERNAME/.zshrc

# Ensure proper ownership
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set Zsh as the default shell
ENV SHELL=/bin/zsh

# Default user is non-root
USER $USERNAME
WORKDIR /home/$USERNAME

CMD ["zsh"]