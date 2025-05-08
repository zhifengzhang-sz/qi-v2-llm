# Managing Secrets in DevContainer Environment

This document explains how to securely manage sensitive information like API keys in the devcontainer environment.

## Setting Up Environment Variables

The recommended way to manage your API keys is through the npm workflow:

1. Run the initial setup (if you haven't already):
   ```bash
   npm run setup
   ```
   This creates a `.env` file with empty API key fields.

2. Set up your DeepSeek API key interactively:
   ```bash
   npm run secrets:setup-deepseek
   ```
   This script will prompt you for your DeepSeek API key and securely add it to your `.env` file.

3. After setting up your secrets, if containers are already running:
   ```bash
   npm run stop
   npm run start
   ```

4. Test your DeepSeek configuration:
   ```bash
   npm run deepseek:test
   ```

## Manual Setup (Alternative)

If you prefer to set up your environment manually:

1. Run the initial setup (if you haven't already):
   ```bash
   npm run setup
   ```

2. Edit the `.env` file with your actual API keys:
   ```bash
   code .devcontainer/.env
   ```

3. Update the values for your API keys:
   ```
   OPENAI_API_KEY=your_actual_openai_key_here
   DEEPSEEK_API_KEY=your_actual_deepseek_key_here
   ```

## Security Notes

- The `.env` file is included in `.gitignore` to prevent it from being committed to the repository
- Each developer maintains their own local copy of the `.env` file
- Never commit API keys or other secrets to the repository
- Consider using a credential manager like [pass](https://www.passwordstore.org/) or [1Password](https://1password.com/) for team-based secret management

## Using DeepSeek with Cursor

1. Set up your DeepSeek API key using the methods above
2. Configure Cursor to use DeepSeek:
   - Open Cursor Settings → Extensions → Cursor
   - Find "AI Model Configuration" section
   - Set Model: "deepseek-coder"
   - Set Base URL: "https://api.deepseek.com/v1"
   - Set API Key: your DeepSeek API key

## Troubleshooting

If you encounter issues with API key configuration:

1. Verify the `.env` file exists and contains the correct values: `cat .devcontainer/.env`
2. Make sure the devcontainer has been rebuilt or restarted after updating the `.env` file
3. Check for any error messages in the terminal or log files