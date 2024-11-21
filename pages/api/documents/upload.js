import { DocumentProcessor } from '../../../lib/document-processor';
import formidable from 'formidable';

export const config = {
    api: {
        bodyParser: false,
    },
};

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ message: 'Method not allowed' });
    }

    try {
        const form = formidable();
        const [fields, files] = await new Promise((resolve, reject) => {
            form.parse(req, (err, fields, files) => {
                if (err) reject(err);
                resolve([fields, files]);
            });
        });

        if (!files.file?.[0]) {
            throw new Error('No file uploaded');
        }

        const processor = new DocumentProcessor();
        const result = await processor.processDocument(files.file[0]);

        console.log('Document processed:', result);
        res.status(200).json({ document: result });
    } catch (error) {
        console.error('Upload error:', error);
        res.status(500).json({ error: error.message });
    }
}
