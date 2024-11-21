#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up Azure OpenAI deployment...${NC}"

# Function to check if Azure CLI is installed
check_az() {
    if ! command -v az &> /dev/null; then
        echo -e "${RED}Azure CLI not found. Installing...${NC}"
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    fi
}

# Function to check Azure login status
check_login() {
    echo -e "${BLUE}Checking Azure login status...${NC}"
    az account show &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}Not logged in to Azure. Please login:${NC}"
        az login
    fi
}

# Function to create resource group
create_resource_group() {
    local rg_name=$1
    local location=$2
    echo -e "${BLUE}Creating resource group: $rg_name${NC}"
    az group create --name $rg_name --location $location
}

# Function to create Azure OpenAI resource
create_openai_resource() {
    local rg_name=$1
    local openai_name=$2
    local location=$3
    
    echo -e "${BLUE}Creating Azure OpenAI resource: $openai_name${NC}"
    az cognitiveservices account create \
        --name $openai_name \
        --resource-group $rg_name \
        --kind OpenAI \
        --sku S0 \
        --location $location \
        --custom-domain $openai_name
}

# Function to deploy GPT model
deploy_gpt_model() {
    local rg_name=$1
    local openai_name=$2
    
    echo -e "${BLUE}Deploying GPT-3.5 Turbo model...${NC}"
    az cognitiveservices account deployment create \
        --name $openai_name \
        --resource-group $rg_name \
        --deployment-name "gpt-35-turbo" \
        --model-name "gpt-35-turbo" \
        --model-version "0613" \
        --model-format OpenAI \
        --sku-capacity 1
}

# Function to get credentials and create .env file
setup_env() {
    local rg_name=$1
    local openai_name=$2
    
    echo -e "${BLUE}Getting Azure OpenAI credentials...${NC}"
    
    # Get endpoint
    local endpoint=$(az cognitiveservices account show \
        --name $openai_name \
        --resource-group $rg_name \
        --query properties.endpoint \
        --output tsv)
        
    # Get key
    local key=$(az cognitiveservices account keys list \
        --name $openai_name \
        --resource-group $rg_name \
        --query key1 \
        --output tsv)
    
    # Create .env.local
    echo -e "${GREEN}Creating .env.local file...${NC}"
    cat > .env.local << ENV_EOF
AZURE_OPENAI_ENDPOINT=$endpoint
AZURE_OPENAI_KEY=$key
AZURE_OPENAI_DEPLOYMENT=gpt-35-turbo
ENV_EOF
}

# Main setup function
main() {
    # Configuration
    read -p "Enter resource group name (default: rg-chatwidget): " RG_NAME
    RG_NAME=${RG_NAME:-rg-chatwidget}
    
    read -p "Enter location (default: eastus): " LOCATION
    LOCATION=${LOCATION:-eastus}
    
    read -p "Enter OpenAI resource name (default: oai-chatwidget): " OPENAI_NAME
    OPENAI_NAME=${OPENAI_NAME:-oai-chatwidget}
    
    # Check prerequisites
    check_az
    check_login
    
    # Create resources
    create_resource_group $RG_NAME $LOCATION
    create_openai_resource $RG_NAME $OPENAI_NAME $LOCATION
    deploy_gpt_model $RG_NAME $OPENAI_NAME
    setup_env $RG_NAME $OPENAI_NAME
    
    echo -e "${GREEN}✅ Setup complete!${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Check your .env.local file for the credentials"
    echo "2. Restart your Next.js development server"
    echo "3. Test the chat widget"
    
    # Optional: Deploy to Azure Web App
    read -p "Would you like to deploy the app to Azure Web App? (y/n): " DEPLOY_WEBAPP
    if [[ $DEPLOY_WEBAPP == "y" ]]; then
        echo -e "${BLUE}Setting up Azure Web App...${NC}"
        
        # Create App Service plan
        az appservice plan create \
            --name "plan-$OPENAI_NAME" \
            --resource-group $RG_NAME \
            --sku B1 \
            --is-linux
            
        # Create Web App
        az webapp create \
            --name "app-$OPENAI_NAME" \
            --resource-group $RG_NAME \
            --plan "plan-$OPENAI_NAME" \
            --runtime "NODE|18-lts"
            
        # Configure Web App settings
        az webapp config appsettings set \
            --name "app-$OPENAI_NAME" \
            --resource-group $RG_NAME \
            --settings \
                AZURE_OPENAI_ENDPOINT=$endpoint \
                AZURE_OPENAI_KEY=$key \
                AZURE_OPENAI_DEPLOYMENT=gpt-35-turbo
                
        echo -e "${GREEN}✅ Web App deployment complete!${NC}"
        echo "Your app will be available at: https://app-$OPENAI_NAME.azurewebsites.net"
    fi
}

# Run main function
main
