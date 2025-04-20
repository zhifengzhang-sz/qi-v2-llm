# Multi-Language Development Containers

This project provides a multi-language development environment using Docker containers for TypeScript, Python, and TeX Live. Each language has its own dedicated container, allowing for a seamless development experience.

## Project Structure

```
multi-lang-devcontainers
├── .devcontainer
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── typescript
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   ├── python
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   └── texlive
│       ├── Dockerfile
│       └── devcontainer.json
├── typescript-workspace
│   ├── src
│   │   └── index.ts
│   ├── package.json
│   └── tsconfig.json
├── python-workspace
│   ├── src
│   │   └── main.py
│   └── requirements.txt
├── texlive-workspace
│   └── src
│       └── main.tex
├── .gitignore
└── README.md
```

## Getting Started

To set up the development environment, follow these steps:

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd multi-lang-devcontainers
   ```

2. **Open the project in your code editor.**

3. **Build and start the containers:**
   Use the provided `docker-compose.yml` file to build and start the containers for TypeScript, Python, and TeX Live. You can do this by running:
   ```
   docker-compose up --build
   ```

4. **Access the workspaces:**
   Each language workspace is located in its respective directory:
   - TypeScript: `typescript-workspace`
   - Python: `python-workspace`
   - TeX Live: `texlive-workspace`

## Usage

- For TypeScript development, navigate to the `typescript-workspace` directory and use the TypeScript tools as needed.
- For Python development, navigate to the `python-workspace` directory and run your Python scripts.
- For LaTeX documents, navigate to the `texlive-workspace` directory and compile your `.tex` files.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.