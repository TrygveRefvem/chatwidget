import { AzureOpenAIService } from "../../../lib/azure-openai"

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ message: "Method not allowed" })
  }

  try {
    const { messages } = req.body
    const openAIService = new AzureOpenAIService()
    const completion = await openAIService.generateCompletion(messages)
    
    res.status(200).json({ message: completion })
  } catch (error) {
    console.error("Error:", error)
    res.status(500).json({ error: "Internal server error" })
  }
}
