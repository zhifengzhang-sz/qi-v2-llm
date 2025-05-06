# TeXLive development container
FROM qi-v2-llm-base:latest

# Get the username from build arg
ARG USERNAME=vscode

USER root

# Install TeXLive and related tools
RUN apt-get update && apt-get install -y \
    texlive \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-xetex \
    latexmk \
    && rm -rf /var/lib/apt/lists/*

# Add LaTeX specific plugins to Oh My Zsh configuration
RUN sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git latex zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc && \
    sed -i 's/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/plugins=(git latex zsh-autosuggestions zsh-syntax-highlighting)/' /home/${USERNAME}/.zshrc

# Create LaTeX specific setup file
RUN echo '# LaTeX environment setup\n\
\n\
# LaTeX aliases\n\
alias pdflatex="pdflatex -interaction=nonstopmode"\n\
alias bibtex="bibtex -terse"\n\
alias latexmk="latexmk -pdf -interaction=nonstopmode"\n\
' > /etc/zsh/zshrc.d/texlive-setup.zsh

# Update both root and user .zshrc files to source the TeXLive setup
RUN echo 'source /etc/zsh/zshrc.d/texlive-setup.zsh' >> /root/.zshrc && \
    echo 'source /etc/zsh/zshrc.d/texlive-setup.zsh' >> /home/${USERNAME}/.zshrc

USER ${USERNAME}
WORKDIR /workspace

CMD ["zsh"]