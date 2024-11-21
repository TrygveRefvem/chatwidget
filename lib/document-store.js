let documents = new Map();

// Singleton instance
class DocumentStore {
    constructor() {
        // Ensure documents persist across hot reloads
        if (global.documentStore) {
            return global.documentStore;
        }
        global.documentStore = this;
    }

    addDocument(id, content) {
        console.log(`Adding document ${id} to store`);
        console.log('Content sample:', content.substring(0, 200) + '...');
        documents.set(id, content);
        console.log(`Store now has ${documents.size} documents:`, Array.from(documents.keys()));
        return id;
    }

    getDocument(id) {
        console.log(`Attempting to retrieve document ${id}`);
        console.log(`Available documents:`, Array.from(documents.keys()));
        const content = documents.get(id);
        if (content) {
            console.log(`Found document, length: ${content.length}`);
            return content;
        }
        console.log('Document not found');
        return null;
    }

    getAllDocuments() {
        return Array.from(documents.entries());
    }

    clear() {
        documents.clear();
    }
}

// Create singleton instance
const store = global.documentStore || new DocumentStore();
if (!global.documentStore) global.documentStore = store;

export default store;
