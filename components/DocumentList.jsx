export default function DocumentList() {
 const [docs, setDocs] = useState([])

 useEffect(() => {
   fetch('/api/documents/list')
     .then(res => res.json())
     .then(setDocs)
 }, [])

 return (
   <div className="mt-4">
     <h3 className="font-semibold mb-2">Dokumenter</h3>
     <div className="space-y-2">
       {docs.map(doc => (
         <div key={doc.name} className="flex justify-between items-center p-2 bg-gray-50 rounded">
           <div>
             <p className="font-medium">{doc.name}</p>
             <p className="text-sm text-gray-500">
               {new Date(doc.uploaded).toLocaleString()}
             </p>
           </div>
           <div className={`px-2 py-1 rounded ${
             doc.indexed ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
           }`}>
             {doc.indexed ? 'Indeksert' : 'Venter'}
           </div>
         </div>
       ))}
     </div>
   </div>
 )
}
