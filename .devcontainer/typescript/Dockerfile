FROM node:14

# Set the working directory
WORKDIR /workspace

# Install TypeScript globally
RUN npm install -g typescript

# Copy package.json and install dependencies
COPY ../typescript-workspace/package.json ./
RUN npm install

# Copy the rest of the workspace files
COPY ../typescript-workspace ./

# Expose the port for the TypeScript application
EXPOSE 3000

# Command to run the TypeScript application
CMD ["npm", "start"]