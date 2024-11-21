import { BlobServiceClient } from "@azure/storage-blob"

export default async function handler(req, res) {
  try {
    const blobClient = BlobServiceClient.fromConnectionString(
      process.env.AZURE_STORAGE_CONNECTION_STRING
    )
    const containerClient = blobClient.getContainerClient("documents")
    await containerClient.createIfNotExists()

    const blobs = []
    for await (const blob of containerClient.listBlobsFlat()) {
      blobs.push({
        name: blob.name,
        size: blob.properties.contentLength,
        uploaded: blob.properties.createdOn,
        indexed: true // Simplified for now
      })
    }

    res.status(200).json({ documents: blobs })
  } catch (error) {
    console.error("List documents error:", error)
    res.status(500).json({ error: error.message })
  }
}
