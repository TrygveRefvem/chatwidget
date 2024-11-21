import { OpenAIClient, AzureKeyCredential } from "@azure/openai"
import { BlobServiceClient } from "@azure/storage-blob"

export class AzureOpenAIService {
  constructor() {
    this.client = new OpenAIClient(
      process.env.AZURE_OPENAI_ENDPOINT,
      new AzureKeyCredential(process.env.AZURE_OPENAI_KEY)
    )
    
    this.blobServiceClient = BlobServiceClient.fromConnectionString(
      process.env.AZURE_STORAGE_CONNECTION_STRING
    )
    this.deploymentName = process.env.AZURE_OPENAI_DEPLOYMENT
  }

  async generateCompletion(messages, context = null) {
    try {
      let systemMessage = {
        role: "system",
        content: "Du er en hjelpsom assistent. Du svarer på norsk og er alltid høflig og presis."
      }

      if (context) {
        systemMessage.content += `\n\nDokumentkontekst:\n${context}`
      }

      const allMessages = [systemMessage, ...messages]

      const response = await this.client.getChatCompletions(
        this.deploymentName,
        allMessages,
        {
          temperature: 0.7,
          maxTokens: 800,
        }
      )

      return response.choices[0].message
    } catch (error) {
      console.error("Azure OpenAI Error:", error)
      throw error
    }
  }

  async getDocumentContent(blobName) {
    const containerClient = this.blobServiceClient.getContainerClient("documents")
    const blobClient = containerClient.getBlobClient(blobName)
    const downloadResponse = await blobClient.download()
    return await streamToString(downloadResponse.readableStreamBody)
  }
}

async function streamToString(readableStream) {
  return new Promise((resolve, reject) => {
    const chunks = []
    readableStream.on('data', (data) => chunks.push(data.toString()))
    readableStream.on('end', () => resolve(chunks.join('')))
    readableStream.on('error', reject)
  })
}
