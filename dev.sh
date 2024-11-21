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
    case $choice in
        1) start_dev ;;
        2) run_tests ;;
        3) build_prod ;;
        4) deploy_azure ;;
        q) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
