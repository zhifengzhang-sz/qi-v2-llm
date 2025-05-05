# TypeScript development container
FROM qi-v2-llm-base:latest

USER root

# Install Node.js and npm
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install n for managing Node.js versions
RUN npm install -g n

# Install latest stable version of Node.js using n
RUN n stable

# Install TypeScript globally
RUN npm install -g typescript

# Add Node.js/TypeScript specific plugins to Oh My Zsh configuration
RUN sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc && \
    sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)/' /home/$USERNAME/.zshrc

# Add Node.js/TypeScript specific auto-completion
RUN echo '# Node.js/TypeScript autocompletion\n\
# npm completion\n\
if type npm &>/dev/null; then\n\
  eval "$(npm completion)"\n\
fi\n\
' >> /etc/zsh/zshrc.d/auto-completion.zsh

# Add Node.js/TypeScript specific environment setup
RUN echo '# Node.js/TypeScript environment setup\n\
export NODE_PATH=$(npm root -g)\n\
export PATH=$(npm bin -g):$PATH\n\
\n\
# Node.js/TypeScript aliases\n\
alias tsc="npx tsc"\n\
alias ts-node="npx ts-node"\n\
' >> /etc/zsh/zshrc.d/typescript-setup.zsh

# Update both root and user .zshrc files to source the TypeScript setup
RUN echo 'source /etc/zsh/zshrc.d/typescript-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/typescript-setup.zsh' >> /home/$USERNAME/.zshrc

# Make sure all files in the home directory are owned by the user
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /workspace

CMD ["zsh"]