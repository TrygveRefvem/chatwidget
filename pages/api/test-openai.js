import { AzureOpenAIService } from "../../lib/azure-openai"

export default async function handler(req, res) {
  try {
    const openAIService = new AzureOpenAIService()
    const testMessage = {
      role: "user",
      content: "Si hei og fortell meg hvilken modell du bruker."
    }

    console.log("Testing OpenAI connection...")
    const response = await openAIService.generateCompletion([testMessage])
    
    res.status(200).json({
      success: true,
      message: response,
      config: {
        endpoint: process.env.AZURE_OPENAI_ENDPOINT,
        deployment: process.env.AZURE_OPENAI_DEPLOYMENT,
        apiVersion: process.env.AZURE_OPENAI_API_VERSION
      }
    })
  } catch (error) {
    console.error("Test endpoint error:", error)
    res.status(500).json({
      success: false,
      error: error.message,
      config: {
        endpoint: process.env.AZURE_OPENAI_ENDPOINT,
        deployment: process.env.AZURE_OPENAI_DEPLOYMENT,
        apiVersion: process.env.AZURE_OPENAI_API_VERSION
      }
    })
  }
}
