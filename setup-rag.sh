#!/bin/bash

# Set variables
RG_NAME="rg-chatwidget"
LOCATION="eastus"
SEARCH_NAME="search-chatwidget"
STORAGE_NAME="stchatwidget"
FORM_RECOGNIZER_NAME="fr-chatwidget"

# Create Azure Cognitive Search
az search service create \
    --name $SEARCH_NAME \
    --resource-group $RG_NAME \
    --sku Basic \
    --location $LOCATION

# Create Azure Storage Account
az storage account create \
    --name $STORAGE_NAME \
    --resource-group $RG_NAME \
    --location $LOCATION \
    --sku Standard_LRS

# Create container
az storage container create \
    --name documents \
    --account-name $STORAGE_NAME \
    --auth-mode login

# Create Form Recognizer (for PDF processing)
az cognitiveservices account create \
    --name $FORM_RECOGNIZER_NAME \
    --resource-group $RG_NAME \
    --kind FormRecognizer \
    --sku S0 \
    --location $LOCATION

# Get credentials
SEARCH_KEY=$(az search admin-key show --service-name $SEARCH_NAME --resource-group $RG_NAME --query primaryKey -o tsv)
STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_NAME --resource-group $RG_NAME --query '[0].value' -o tsv)
FR_KEY=$(az cognitiveservices account keys list --name $FORM_RECOGNIZER_NAME --resource-group $RG_NAME --query 'key1' -o tsv)

# Update .env.local
cat >> .env.local << ENV_EOF

# RAG Configuration
AZURE_SEARCH_ENDPOINT=https://$SEARCH_NAME.search.windows.net
AZURE_SEARCH_KEY=$SEARCH_KEY
AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $STORAGE_NAME --resource-group $RG_NAME --query connectionString -o tsv)
AZURE_FORM_RECOGNIZER_ENDPOINT=https://$LOCATION.form.cognitive.microsoft.com/
AZURE_FORM_RECOGNIZER_KEY=$FR_KEY
ENV_EOF

echo "Setup complete! Check .env.local for credentials."
