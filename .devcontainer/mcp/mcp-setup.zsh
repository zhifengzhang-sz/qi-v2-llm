# MCP (Model Context Protocol) setup

# Source Python and TypeScript environments
if [ -f /etc/zsh/zshrc.d/python-setup.zsh ]; then
  source /etc/zsh/zshrc.d/python-setup.zsh
fi

if [ -f /etc/zsh/zshrc.d/typescript-setup.zsh ]; then
  source /etc/zsh/zshrc.d/typescript-setup.zsh
fi

# MCP specific aliases and functions
mcp-init() {
  echo "Initializing new MCP project..."
  mkdir -p server client
  
  # Set up Python server
  cd server
  pip install fastapi uvicorn python-dotenv pydantic
  touch __init__.py
  
  # Create basic server file
  cat > server.py << EOF
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Message(BaseModel):
    content: str

@app.get("/")
async def root():
    return {"message": "MCP Server is running"}

@app.post("/message")
async def process_message(message: Message):
    return {"processed": message.content}
EOF
  
  # Create start script
  cat > start.sh << EOF
#!/bin/bash
uvicorn server:app --reload --host 0.0.0.0 --port 8000
EOF
  chmod +x start.sh
  
  cd ../client
  
  # Initialize TypeScript project
  npm init -y
  npm install --save-dev typescript ts-node @types/node
  
  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.spec.ts"]
}
EOF
  
  # Create client source directory
  mkdir -p src
  
  # Create basic client file
  cat > src/client.ts << EOF
interface Message {
  content: string;
}

async function sendMessage(message: string): Promise<any> {
  const response = await fetch('http://localhost:8000/message', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ content: message }),
  });
  return response.json();
}

// Example usage
async function main() {
  try {
    const result = await sendMessage('Hello from TypeScript client');
    console.log('Response:', result);
  } catch (error) {
    console.error('Error:', error);
  }
}

main();
EOF
  
  # Update package.json scripts
  sed -i '/"scripts": {/,/},/ c\\
  "scripts": {\\
    "build": "tsc",\\
    "start": "ts-node src/client.ts"\\
  },\\
' package.json
  
  cd ..
  echo "MCP project initialized successfully!"
  echo "To start the server: cd server && ./start.sh"
  echo "To run the client: cd client && npm start"
}