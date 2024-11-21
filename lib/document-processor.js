import documentStore from './document-store';
import pdfParse from 'pdf-parse';

export class DocumentProcessor {
    async processDocument(file) {
        console.log(`Processing document: ${file.originalFilename}`);
        try {
            const fileBuffer = await this.readFileBuffer(file);
            let textContent = '';

            if (file.mimetype === 'application/pdf') {
                console.log('Processing PDF file...');
                const pdfData = await pdfParse(fileBuffer);
                textContent = pdfData.text;
                console.log(`PDF content extracted, length: ${textContent.length}`);
            } else {
                textContent = fileBuffer.toString('utf-8');
            }

            const documentId = `${Date.now()}-${file.originalFilename}`;
            
            // Store the document
            documentStore.addDocument(documentId, textContent);
            
            // Verify storage
            const stored = documentStore.getDocument(documentId);
            if (!stored) {
                throw new Error('Document storage verification failed');
            }
            
            console.log(`Document successfully stored with ID: ${documentId}`);

            return {
                id: documentId,
                filename: file.originalFilename,
                contentLength: textContent.length,
                sampleContent: textContent.substring(0, 100)
            };
        } catch (error) {
            console.error('Document processing error:', error);
            throw error;
        }
    }

    async readFileBuffer(file) {
        const fs = require('fs');
        return fs.readFileSync(file.filepath);
    }
}
