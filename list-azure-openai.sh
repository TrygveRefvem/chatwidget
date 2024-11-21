#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check Azure CLI is installed
check_az() {
    if ! command -v az &> /dev/null; then
        echo -e "${RED}Azure CLI not found. Installing...${NC}"
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    fi
}

# Function to check Azure OpenAI extension
check_openai_extension() {
    if ! az extension show --name azure-ai-ml &>/dev/null; then
        echo -e "${BLUE}Installing Azure OpenAI extension...${NC}"
        az extension add --name azure-ai-ml
    fi
}

# Function to check login status
check_login() {
    echo -e "${BLUE}Checking Azure login status...${NC}"
    az account show &> /dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}Not logged in to Azure. Please login:${NC}"
        az login
    fi
}

# Function to list all resource groups with OpenAI resources
list_openai_resources() {
    echo -e "${BLUE}Listing Azure OpenAI resources...${NC}"
    az cognitiveservices account list --query "[?kind=='OpenAI']" -o table
}

# Function to list deployments for a specific OpenAI resource
list_deployments() {
    local resource_group=$1
    local resource_name=$2
    
    echo -e "${BLUE}Listing deployments for $resource_name...${NC}"
    az cognitiveservices account deployment list \
        --name "$resource_name" \
        --resource-group "$resource_group" \
        -o table
}

# Function to get deployment details
get_deployment_details() {
    local resource_group=$1
    local resource_name=$2
    local deployment_name=$3
    
    echo -e "${BLUE}Getting details for deployment $deployment_name...${NC}"
    az cognitiveservices account deployment show \
        --name "$resource_name" \
        --resource-group "$resource_group" \
        --deployment-id "$deployment_name" \
        -o json
}

# Function to get quota information
get_quota_info() {
    local resource_group=$1
    local resource_name=$2
    
    echo -e "${BLUE}Getting quota information for $resource_name...${NC}"
    az cognitiveservices account list-usage \
        --name "$resource_name" \
        --resource-group "$resource_group" \
        -o table
}

# Main menu function
show_menu() {
    echo -e "${GREEN}Azure OpenAI Management${NC}"
    echo "1) List all OpenAI resources"
    echo "2) List deployments for a specific resource"
    echo "3) Get deployment details"
    echo "4) Get quota information"
    echo "5) Create new deployment"
    echo "q) Quit"
}

# Create deployment function
create_deployment() {
    local resource_group=$1
    local resource_name=$2
    
    echo -e "${BLUE}Available models:${NC}"
    echo "1) gpt-35-turbo"
    echo "2) gpt-4"
    echo "3) text-embedding-ada-002"
    
    read -p "Select model (1-3): " model_choice
    
    case $model_choice in
        1) 
            model_name="gpt-35-turbo"
            model_version="0613"
            ;;
        2) 
            model_name="gpt-4"
            model_version="0613"
            ;;
        3) 
            model_name="text-embedding-ada-002"
            model_version="2"
            ;;
        *) 
            echo -e "${RED}Invalid choice${NC}"
            return
            ;;
    esac
    
    read -p "Enter deployment name: " deployment_name
    
    echo -e "${BLUE}Creating deployment $deployment_name with model $model_name...${NC}"
    az cognitiveservices account deployment create \
        --name "$resource_name" \
        --resource-group "$resource_group" \
        --deployment-name "$deployment_name" \
        --model-name "$model_name" \
        --model-version "$model_version" \
        --model-format OpenAI \
        --sku-capacity 1
}

# Main script
main() {
    check_az
    check_openai_extension
    check_login
    
    while true; do
        show_menu
        read -p "Select an option: " choice
        
        case $choice in
            1)
                list_openai_resources
                ;;
            2)
                list_openai_resources
                read -p "Enter resource group name: " rg_name
                read -p "Enter resource name: " res_name
                list_deployments "$rg_name" "$res_name"
                ;;
            3)
                list_openai_resources
                read -p "Enter resource group name: " rg_name
                read -p "Enter resource name: " res_name
                list_deployments "$rg_name" "$res_name"
                read -p "Enter deployment name: " dep_name
                get_deployment_details "$rg_name" "$res_name" "$dep_name"
                ;;
            4)
                list_openai_resources
                read -p "Enter resource group name: " rg_name
                read -p "Enter resource name: " res_name
                get_quota_info "$rg_name" "$res_name"
                ;;
            5)
                list_openai_resources
                read -p "Enter resource group name: " rg_name
                read -p "Enter resource name: " res_name
                create_deployment "$rg_name" "$res_name"
                ;;
            q)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
        clear
    done
}

# Run main function
main
