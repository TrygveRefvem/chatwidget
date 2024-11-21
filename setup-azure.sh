#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Azure OpenAI Setup...${NC}"

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

# Function to deploy models
deploy_models() {
    local rg_name=$1
    local openai_name=$2
    
    echo -e "${BLUE}Deploying GPT-3.5 Turbo model...${NC}"
    az cognitiveservices account deployment create \
        --name $openai_name \
        --resource-group $rg_name \
        --deployment-name "chat" \
        --model-name "gpt-35-turbo" \
        --model-version "0613" \
        --model-format OpenAI \
        --sku Standard \
        --capacity 1
        
    echo -e "${BLUE}Deploying text-embedding-ada-002 model...${NC}"
    az cognitiveservices account deployment create \
        --name $openai_name \
        --resource-group $rg_name \
        --deployment-name "embedding" \
        --model-name "text-embedding-ada-002" \
        --model-version "2" \
        --model-format OpenAI \
        --sku Standard \
        --capacity 1
}

# Function to get keys and endpoint
get_credentials() {
    local rg_name=$1
    local openai_name=$2
    
    echo -e "${BLUE}Getting Azure OpenAI credentials...${NC}"
    local endpoint=$(az cognitiveservices account show \
        --name $openai_name \
        --resource-group $rg_name \
        --query properties.endpoint \
        --output tsv)
        
    local key=$(az cognitiveservices account keys list \
        --name $openai_name \
        --resource-group $rg_name \
        --query key1 \
        --output tsv)
        
    echo -e "${GREEN}Creating .env.local file...${NC}"
    cat > .env.local << EOF
AZURE_OPENAI_ENDPOINT=$endpoint
AZURE_OPENAI_KEY=$key
AZURE_OPENAI_DEPLOYMENT=chat
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=embedding
EOF
}

# Function to create Azure Search
create_search() {
    local rg_name=$1
    local search_name=$2
    local location=$3
    
    echo -e "${BLUE}Creating Azure Search service...${NC}"
    az search service create \
        --name $search_name \
        --resource-group $rg_name \
        --sku Basic \
        --location $location
        
    local search_endpoint="https://$search_name.search.windows.net"
    local search_key=$(az search admin-key show \
        --resource-group $rg_name \
        --service-name $search_name \
        --query primaryKey \
        --output tsv)
        
    echo -e "${BLUE}Updating .env.local with Search credentials...${NC}"
    cat >> .env.local << EOF
AZURE_SEARCH_ENDPOINT=$search_endpoint
AZURE_SEARCH_KEY=$search_key
AZURE_SEARCH_INDEX=chat-index
EOF
}

# Function to create Azure Storage
create_storage() {
    local rg_name=$1
    local storage_name=$2
    local location=$3
    
    echo -e "${BLUE}Creating Azure Storage account...${NC}"
    az storage account create \
        --name $storage_name \
        --resource-group $rg_name \
        --location $location \
        --sku Standard_LRS \
        --kind StorageV2
        
    local connection_string=$(az storage account show-connection-string \
        --name $storage_name \
        --resource-group $rg_name \
        --query connectionString \
        --output tsv)
        
    echo -e "${BLUE}Updating .env.local with Storage credentials...${NC}"
    cat >> .env.local << EOF
AZURE_STORAGE_CONNECTION_STRING=$connection_string
EOF
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
    
    read -p "Enter Search service name (default: search-chatwidget): " SEARCH_NAME
    SEARCH_NAME=${SEARCH_NAME:-search-chatwidget}
    
    read -p "Enter Storage account name (default: stchatwidget): " STORAGE_NAME
    STORAGE_NAME=${STORAGE_NAME:-stchatwidget}
    
    # Check prerequisites
    check_az
    check_login
    
    # Create resources
    create_resource_group $RG_NAME $LOCATION
    create_openai_resource $RG_NAME $OPENAI_NAME $LOCATION
    deploy_models $RG_NAME $OPENAI_NAME
    create_search $RG_NAME $SEARCH_NAME $LOCATION
    create_storage $RG_NAME $STORAGE_NAME $LOCATION
    get_credentials $RG_NAME $OPENAI_NAME
    
    echo -e "${GREEN}✅ Setup complete! Your .env.local file has been created with all necessary credentials.${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Restart your Next.js development server"
    echo "2. Try sending a message in the chat widget"
}

# Run main function
main
