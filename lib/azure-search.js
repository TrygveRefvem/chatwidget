import { SearchClient, AzureKeyCredential } from "@azure/search-documents"

export class AzureSearchClient {
  constructor() {
    this.client = new SearchClient(
      process.env.AZURE_SEARCH_ENDPOINT,
      "knowledge-base",
      new AzureKeyCredential(process.env.AZURE_SEARCH_KEY)
    )
  }

  async listDocuments() {
    const results = await this.client.search("*")
    const docs = []
    for await (const result of results.results) {
      docs.push(result.document)
    }
    return docs
  }
}
