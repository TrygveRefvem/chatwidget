#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up Git repository...${NC}"

# Get GitHub repository URL
read -p "Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "Error: Repository URL is required"
    exit 1
fi

# Initialize Git if not already initialized
if [ ! -d ".git" ]; then
    git init
    echo -e "${GREEN}Git repository initialized${NC}"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "node_modules
.next
.env*
!.env.example
.DS_Store" > .gitignore
    echo -e "${GREEN}.gitignore created${NC}"
fi

# Create README if it doesn't exist
if [ ! -f "README.md" ]; then
    echo "# Azure OpenAI Chat Widget

A React-based chat widget using Azure OpenAI with document processing capabilities.

## Features
- Real-time chat
- PDF document processing
- Azure OpenAI integration
- Modern UI with Tailwind CSS

## Setup
1. Clone the repository
2. Install dependencies: \`npm install\`
3. Create \`.env.local\` with your Azure credentials
4. Run development server: \`npm run dev\`" > README.md
    echo -e "${GREEN}README.md created${NC}"
fi

# Stage all files
git add .

# Commit
git commit -m "Initial commit: Chat Widget v1.0.0"

# Add remote
git remote remove origin 2>/dev/null
git remote add origin $REPO_URL

# Push to GitHub
echo -e "${BLUE}Pushing to GitHub...${NC}"
git branch -M main
git push -u origin main --force

echo -e "${GREEN}✅ Repository setup complete!${NC}"
echo -e "Your code is now available at: $REPO_URL"
