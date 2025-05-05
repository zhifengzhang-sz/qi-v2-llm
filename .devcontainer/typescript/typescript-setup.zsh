# Node.js/TypeScript environment setup
export NODE_PATH=$(npm root -g)
export PATH=$(npm bin -g):$PATH

# Node.js/TypeScript aliases
alias tsc="npx tsc"
alias ts-node="npx ts-node"