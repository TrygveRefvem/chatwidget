export default async function handler(req, res) {
  const services = {
    storage: {
      connectionString: process.env.AZURE_STORAGE_CONNECTION_STRING ? "Set" : "Missing"
    },
    search: {
      endpoint: process.env.AZURE_SEARCH_ENDPOINT,
      key: process.env.AZURE_SEARCH_KEY ? "Set" : "Missing"
    },
    formRecognizer: {
      endpoint: process.env.AZURE_FORM_RECOGNIZER_ENDPOINT,
      key: process.env.AZURE_FORM_RECOGNIZER_KEY ? "Set" : "Missing"
    },
    openai: {
      endpoint: process.env.AZURE_OPENAI_ENDPOINT,
      deployment: process.env.AZURE_OPENAI_DEPLOYMENT,
      key: process.env.AZURE_OPENAI_KEY ? "Set" : "Missing"
    }
  }

  res.status(200).json(services)
}
