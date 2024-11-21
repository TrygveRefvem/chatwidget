# Azure OpenAI Chat Widget with RAG

A React-based chat widget that uses Azure OpenAI for chat completions and implements Retrieval Augmented Generation (RAG) for document context.

## Features

- 💬 Real-time chat interface
- 📄 PDF document upload and processing
- 🤖 Azure OpenAI integration
- 🔍 Document context in conversations
- 🎨 Modern UI with Tailwind CSS

## Prerequisites

- Node.js 18+
- Azure OpenAI Service
- Azure Blob Storage
- Azure Cognitive Search (optional for future RAG features)

## Environment Variables

Create a `.env.local` file with:

```env
AZURE_OPENAI_ENDPOINT=your-endpoint
AZURE_OPENAI_KEY=your-key
AZURE_OPENAI_DEPLOYMENT=your-deployment
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=your-embedding-deployment
AZURE_STORAGE_CONNECTION_STRING=your-connection-string
2. Create an Azure Pipeline (optional):

```yaml
cat > azure-pipelines.yml << 'EOL'
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: NodeTool@0
  inputs:
    versionSpec: '18.x'
  displayName: 'Install Node.js'

- script: |
    npm install
    npm run build
  displayName: 'npm install and build'

- task: AzureWebApp@1
  inputs:
    azureSubscription: 'Your-Azure-Subscription'
    appName: 'your-app-name'
    package: '$(System.DefaultWorkingDirectory)'
