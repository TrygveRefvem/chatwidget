import documentStore from '../../../lib/document-store';

export default function handler(req, res) {
    const docs = documentStore.getAllDocuments().map(([id, content]) => ({
        id,
        contentLength: content.length,
        preview: content.substring(0, 100)
    }));

    res.status(200).json({
        documentCount: docs.length,
        documents: docs
    });
}
