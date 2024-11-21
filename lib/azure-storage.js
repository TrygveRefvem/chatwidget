import { BlobServiceClient } from "@azure/storage-blob"
import { v4 as uuidv4 } from "uuid"

export class AzureStorageService {
  constructor() {
    if (!process.env.AZURE_STORAGE_CONNECTION_STRING) {
      throw new Error("Missing Azure Storage connection string")
    }
    this.blobServiceClient = BlobServiceClient.fromConnectionString(
      process.env.AZURE_STORAGE_CONNECTION_STRING
    )
    this.containerName = "documents"
  }

  async initContainer() {
    const containerClient = this.blobServiceClient.getContainerClient(this.containerName)
    await containerClient.createIfNotExists()
    return containerClient
  }

  async uploadDocument(file, metadata = {}) {
    const containerClient = await this.initContainer()
    const blobName = `${uuidv4()}-${file.name}`
    const blockBlobClient = containerClient.getBlockBlobClient(blobName)
    
    await blockBlobClient.uploadData(file.buffer, {
      blobHTTPHeaders: { blobContentType: file.mimetype },
      metadata: {
        ...metadata,
        originalName: file.name,
        uploadedAt: new Date().toISOString()
      }
    })

    return {
      blobName,
      url: blockBlobClient.url,
      metadata
    }
  }
}
