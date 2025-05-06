# Python development container
FROM qi-v2-llm-base:latest

# Get the username from build arg
ARG USERNAME=vscode

USER root

# Install Python and related tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3-venv \
    python3-full \
    python3-argcomplete \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install basic packages
RUN pip config set global.timeout 120 && \
    pip install --upgrade pip setuptools wheel

# Add Python-specific plugins to Oh My Zsh configuration
RUN sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git python pip virtualenv zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc && \
    sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git python pip virtualenv zsh-autosuggestions zsh-syntax-highlighting)/' /home/${USERNAME}/.zshrc

# Add Python-specific auto-completion
RUN echo '# Python autocompletion\n\
# Auto-completion for pip\n\
eval "$(pip completion --zsh)"\n\
# Python argcomplete\n\
if command -v register-python-argcomplete > /dev/null; then\n\
  eval "$(register-python-argcomplete --shell zsh python)"\n\
fi\n\
' >> /etc/zsh/zshrc.d/auto-completion.zsh

# Copy the Python setup file into the container
COPY ./python/python-setup.zsh /etc/zsh/zshrc.d/

# Update both root and user .zshrc files to source the Python setup
RUN echo 'source /etc/zsh/zshrc.d/python-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/python-setup.zsh' >> /home/${USERNAME}/.zshrc

# Change ownership of the virtual environment to the non-root user
RUN chown -R ${USERNAME}:${USERNAME} /opt/venv

USER ${USERNAME}
WORKDIR /workspace

CMD ["zsh"]