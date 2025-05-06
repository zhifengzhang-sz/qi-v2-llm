# MCP (Model Context Protocol) development container
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
    nodejs \
    npm \
    libatlas-base-dev \
    gfortran \
    libfreetype6-dev \
    libpng-dev \
    libhdf5-dev \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install basic packages
RUN pip config set global.timeout 180 && \
    pip install --upgrade pip setuptools wheel

# Install n for managing Node.js versions
RUN npm install -g n

# Install latest stable version of Node.js using n
RUN n stable

# Install TypeScript and ts-node globally
RUN npm install -g typescript ts-node

# Add Python and Node.js specific plugins to Oh My Zsh configuration
RUN sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git python pip node npm virtualenv zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc && \
    sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git python pip node npm virtualenv zsh-autosuggestions zsh-syntax-highlighting)/' /home/${USERNAME}/.zshrc

# Add Python and Node.js specific auto-completion
RUN echo '# Python autocompletion\n\
# Auto-completion for pip\n\
eval "$(pip completion --zsh)"\n\
# Python argcomplete\n\
if command -v register-python-argcomplete > /dev/null; then\n\
  eval "$(register-python-argcomplete --shell zsh python)"\n\
fi\n\
\n\
# Node.js/TypeScript autocompletion\n\
# npm completion\n\
if type npm &>/dev/null; then\n\
  eval "$(npm completion)"\n\
fi\n\
' >> /etc/zsh/zshrc.d/auto-completion.zsh

# Copy configuration files from local to container
COPY ./python/python-setup.zsh /etc/zsh/zshrc.d/
COPY ./typescript/typescript-setup.zsh /etc/zsh/zshrc.d/
COPY ./mcp/mcp-setup.zsh /etc/zsh/zshrc.d/

# Source all environment setups in .zshrc
RUN echo 'source /etc/zsh/zshrc.d/python-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/python-setup.zsh' >> /home/${USERNAME}/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/typescript-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/typescript-setup.zsh' >> /home/${USERNAME}/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/mcp-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/mcp-setup.zsh' >> /home/${USERNAME}/.zshrc

# Install common MCP dependencies
RUN pip install fastapi uvicorn python-dotenv pydantic requests

# Install time series research dependencies
RUN pip install numpy pandas matplotlib scipy scikit-learn statsmodels \
    jupyterlab jupyter ipywidgets ipython notebook \
    plotly seaborn bokeh holoviews hvplot \
    pytest hypothesis flake8 black mypy \
    torch torchvision torchaudio tensorflow keras \
    tqdm dask pmdarima

# Install the OpenAI library for cursor integration
RUN pip install openai
RUN npm install -g openai axios

# Change ownership of the virtual environment to the non-root user
RUN chown -R ${USERNAME}:${USERNAME} /opt/venv && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Create workspace directory structure and ensure all directories exist
RUN mkdir -p /workspace/mcp && \
    mkdir -p /workspace/mcp/server/src && \
    mkdir -p /workspace/mcp/server/src/models && \
    mkdir -p /workspace/mcp/server/src/data && \
    mkdir -p /workspace/mcp/server/src/utils && \
    mkdir -p /workspace/mcp/server/src/api && \
    mkdir -p /workspace/mcp/client/src && \
    mkdir -p /workspace/mcp/notebooks && \
    mkdir -p /workspace/mcp/data/raw && \
    mkdir -p /workspace/mcp/data/processed && \
    mkdir -p /workspace/mcp/cursor-client/src && \
    chown -R ${USERNAME}:${USERNAME} /workspace

# Set the working directory
WORKDIR /workspace/mcp

# Create __init__.py files for Python package structure
RUN touch /workspace/mcp/server/src/__init__.py && \
    touch /workspace/mcp/server/src/models/__init__.py && \
    touch /workspace/mcp/server/src/data/__init__.py && \
    touch /workspace/mcp/server/src/utils/__init__.py && \
    touch /workspace/mcp/server/src/api/__init__.py && \
    chown ${USERNAME}:${USERNAME} /workspace/mcp/server/src/__init__.py && \
    chown ${USERNAME}:${USERNAME} /workspace/mcp/server/src/models/__init__.py && \
    chown ${USERNAME}:${USERNAME} /workspace/mcp/server/src/data/__init__.py && \
    chown ${USERNAME}:${USERNAME} /workspace/mcp/server/src/utils/__init__.py && \
    chown ${USERNAME}:${USERNAME} /workspace/mcp/server/src/api/__init__.py

# Switch to non-root user
USER ${USERNAME}

CMD ["zsh"]