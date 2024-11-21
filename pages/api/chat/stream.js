import { AzureOpenAIService } from "../../../lib/azure-openai";
import documentStore from '../../../lib/document-store';

export default async function handler(req, res) {
    if (req.method !== "POST") {
        return res.status(405).json({ message: "Method not allowed" });
    }

    try {
        const { messages, documentId } = req.body;
        console.log("Processing chat request with document:", documentId);

        const openAIService = new AzureOpenAIService();
        let contextMessage = {
            role: "system",
            content: "Du er en hjelpsom assistent. Du svarer på norsk og er alltid høflig og presis."
        };

        if (documentId) {
            console.log('Looking up document:', documentId);
            const documentContent = documentStore.getDocument(documentId);
            if (documentContent) {
                console.log(`Adding document content to context (length: ${documentContent.length})`);
                contextMessage.content += `\n\nHer er innholdet i dokumentet som ble lastet opp:\n${documentContent}`;
            } else {
                console.log('No document content found');
            }
        }

        const allMessages = [contextMessage, ...messages];
        console.log('Sending messages to OpenAI:', allMessages.map(m => ({ role: m.role, contentLength: m.content.length })));
        
        const completion = await openAIService.generateCompletion(allMessages);
        res.status(200).json({ message: completion });
    } catch (error) {
        console.error("Chat Error:", error);
        res.status(500).json({ error: error.message });
    }
}
