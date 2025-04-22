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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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

# Create directories if they don't exist
RUN mkdir -p /etc/zsh/zshrc.d

# Set up Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure Oh My Zsh with plugins
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

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
RUN echo 'source /etc/zsh/zshrc.d/custom-setup.zsh' >> ~/.zshrc \
    && echo 'source /etc/zsh/zshrc.d/auto-completion.zsh' >> ~/.zshrc

# Set up Oh My Zsh for the user
RUN su $USERNAME -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Set working directory
WORKDIR /workspace/texlive-workspace

# Set Zsh as default shell
ENV SHELL=/bin/zsh

# Default command
USER $USERNAME
CMD ["zsh"]