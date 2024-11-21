#!/bin/bash
# Setup script for Azure Chat Widget development environment

echo "🚀 Setting up Azure Chat Widget development environment..."

# Check for required tools
check_requirements() {
    echo "📋 Checking requirements..."
    
    if ! command -v node >/dev/null 2>&1; then
        echo "❌ Node.js is required but not installed. Please install Node.js first."
        exit 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        echo "❌ Git is required but not installed. Please install Git first."
        exit 1
    fi

    if ! command -v code >/dev/null 2>&1; then
        echo "❌ Visual Studio Code is required but not installed. Please install VS Code first."
        exit 1
    fi

    if ! command -v az >/dev/null 2>&1; then
        echo "❌ Azure CLI is required but not installed. Please install Azure CLI first."
        exit 1
    fi

    if ! command -v terraform >/dev/null 2>&1; then
        echo "⚠️ Terraform not found. Will skip Terraform setup."
        SKIP_TERRAFORM=true
    fi
}

# Initialize Git repository
setup_git() {
    echo "🔧 Setting up Git repository..."
    git init
    
    # Create .gitignore
    cat > .gitignore << GITIGNORE
node_modules
.next
.env.local
.env.*.local
.DS_Store
*.pem
coverage
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
.idea
*.tsbuildinfo
GITIGNORE

    # Create initial commit
    git add .
    git commit -m "Initial commit"
}

# Setup VS Code configuration
setup_vscode() {
    echo "🔧 Setting up VS Code configuration..."
    
    # Create .vscode directory
    mkdir -p .vscode
    
    # Create VS Code settings
    cat > .vscode/settings.json << VSCODE_SETTINGS
{
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "files.associations": {
        "*.css": "tailwindcss"
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[javascriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
}
VSCODE_SETTINGS

    # Create VS Code extensions recommendations
    cat > .vscode/extensions.json << VSCODE_EXTENSIONS
{
    "recommendations": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "bradlc.vscode-tailwindcss",
        "ms-azuretools.vscode-azurefunctions",
        "ms-vscode.azure-account",
        "hashicorp.terraform"
    ]
}
VSCODE_EXTENSIONS

    # Install recommended VS Code extensions
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension bradlc.vscode-tailwindcss
    code --install-extension ms-azuretools.vscode-azurefunctions
    code --install-extension ms-vscode.azure-account
    code --install-extension hashicorp.terraform
}

# Setup Next.js project
setup_nextjs() {
    echo "🔧 Setting up Next.js project..."
    
    # Initialize package.json
    npm init -y
    
    # Install dependencies
    npm install next@latest react@latest react-dom@latest
    npm install @azure/openai @azure/storage-blob @azure/search-documents
    npm install lucide-react
    npm install -D tailwindcss postcss autoprefixer
    npm install @radix-ui/react-alert-dialog @radix-ui/react-slot clsx class-variance-authority
    
    # Initialize Next.js configuration
    cat > next.config.js << NEXT_CONFIG
module.exports = {
  reactStrictMode: true,
  webpack: (config) => {
    config.experiments = { ...config.experiments, topLevelAwait: true }
    return config
  }
}
NEXT_CONFIG

    # Initialize Tailwind CSS
    npx tailwindcss init -p
}

# Create development script
create_dev_script() {
    echo "🔧 Creating development script..."
    
    cat > dev.sh << DEV_SCRIPT
#!/bin/bash

# Start development environment
start_dev() {
    echo "🚀 Starting development environment..."
    npm run dev
}

# Run tests
run_tests() {
    echo "🧪 Running tests..."
    npm test
}

# Build for production
build_prod() {
    echo "📦 Building for production..."
    npm run build
}

# Deploy to Azure
deploy_azure() {
    echo "☁️ Deploying to Azure..."
    cd terraform && terraform apply
}

# Show menu
show_menu() {
    echo "📋 Development Menu"
    echo "1) Start development server"
    echo "2) Run tests"
    echo "3) Build for production"
    echo "4) Deploy to Azure"
    echo "q) Quit"
}

# Main menu loop
while true; do
    show_menu
    read -p "Select an option: " choice
    case \$choice in
        1) start_dev ;;
        2) run_tests ;;
        3) build_prod ;;
        4) deploy_azure ;;
        q) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
DEV_SCRIPT

    chmod +x dev.sh
}

# Main setup
main() {
    check_requirements
    setup_git
    setup_vscode
    setup_nextjs
    create_dev_script
    
    echo "✅ Setup complete! Next steps:"
    echo "1. Copy .env.local.example to .env.local and fill in your Azure credentials"
    echo "2. Run './dev.sh' to start development"
    echo "3. Create a new GitHub repository and push your code"
    echo "4. Configure GitHub Actions secrets for Azure deployment"
}

main
