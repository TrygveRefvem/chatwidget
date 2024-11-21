import React, { useState, useRef, useEffect } from "react"
import { MessageSquare, X, Minimize2, Send, Bot, User, Paperclip, Loader, FileText } from "lucide-react"

const FloatingChatWidget = () => {
 const [isExpanded, setIsExpanded] = useState(false)
 const [messages, setMessages] = useState([])
 const [inputMessage, setInputMessage] = useState("")
 const [isLoading, setIsLoading] = useState(false)
 const [isUploading, setIsUploading] = useState(false)
 const [currentDocument, setCurrentDocument] = useState(null)
 const messagesEndRef = useRef(null)
 const fileInputRef = useRef(null)

 const scrollToBottom = () => {
   messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
 }

 useEffect(() => {
   scrollToBottom()
 }, [messages])

 const handleFileUpload = async (event) => {
   const file = event.target.files?.[0]
   if (!file) return

   setIsUploading(true)
   const formData = new FormData()
   formData.append('file', file)

   try {
     const response = await fetch('/api/documents/upload', {
       method: 'POST',
       body: formData
     })

     if (!response.ok) {
       throw new Error('Upload failed')
     }

     const data = await response.json()
     setCurrentDocument(data.document)
     setMessages(prev => [...prev, {
       role: 'system',
       content: `✅ Dokument lastet opp: ${file.name}`
     }])
   } catch (error) {
     console.error('Upload error:', error)
     setMessages(prev => [...prev, {
       role: 'system',
       content: `❌ Kunne ikke laste opp dokument: ${error.message}`
     }])
   } finally {
     setIsUploading(false)
     if (fileInputRef.current) {
       fileInputRef.current.value = ''
     }
   }
 }

 const handleSendMessage = async (e) => {
   e?.preventDefault()
   if (!inputMessage.trim() || isLoading) return

   const newMessage = {
     role: "user",
     content: inputMessage
   }

   setMessages(prev => [...prev, newMessage])
   setInputMessage("")
   setIsLoading(true)

   try {
     const response = await fetch("/api/chat/stream", {
       method: "POST",
       headers: {
         "Content-Type": "application/json",
       },
       body: JSON.stringify({
         messages: [...messages, newMessage],
         documentId: currentDocument?.id // Include document context if available
       })
     })

     if (!response.ok) {
       throw new Error(`HTTP error! status: ${response.status}`)
     }

     const data = await response.json()

     if (data.message) {
       setMessages(prev => [...prev, {
         role: "assistant",
         content: data.message.content
       }])
     }
   } catch (error) {
     console.error("Error:", error)
     setMessages(prev => [...prev, {
       role: "assistant",
       content: "Beklager, jeg møtte på en feil. Vennligst prøv igjen."
     }])
   } finally {
     setIsLoading(false)
   }
 }

 if (!isExpanded) {
   return (
     <div className="fixed bottom-4 right-4 flex flex-col items-center">
       <button
         onClick={() => setIsExpanded(true)}
         className="w-16 h-16 bg-white rounded-full shadow-lg hover:shadow-xl transition-shadow duration-200 flex flex-col items-center justify-center"
       >
         <MessageSquare className="w-8 h-8 text-blue-600" />
         <span className="text-sm mt-1">Chat</span>
       </button>
     </div>
   )
 }

 return (
   <div className="fixed bottom-4 right-4 w-96 h-[600px] bg-white rounded-lg shadow-xl flex flex-col">
     <div className="p-4 border-b flex justify-between items-center bg-blue-600 text-white">
       <h2 className="font-semibold flex items-center">
         <Bot className="w-5 h-5 mr-2" />
         AI Assistent {currentDocument && `- ${currentDocument.filename}`}
       </h2>
       <div className="flex space-x-2">
         <button
           onClick={() => setIsExpanded(false)}
           className="p-1 hover:bg-blue-700 rounded"
         >
           <Minimize2 className="w-5 h-5" />
         </button>
         <button
           onClick={() => setIsExpanded(false)}
           className="p-1 hover:bg-blue-700 rounded"
         >
           <X className="w-5 h-5" />
         </button>
       </div>
     </div>

     <div className="flex-1 overflow-y-auto p-4 space-y-4">
       {messages.map((message, index) => (
         <div
           key={index}
           className={`flex items-start space-x-2 ${
             message.role === "user" ? "justify-end" : "justify-start"
           }`}
         >
           {message.role === "assistant" && (
             <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
               <Bot className="w-5 h-5 text-blue-600" />
             </div>
           )}
           <div
             className={`max-w-[70%] p-3 rounded-lg ${
               message.role === "user"
                 ? "bg-blue-600 text-white"
                 : message.role === "system"
                 ? "bg-gray-100 text-gray-800"
                 : "bg-gray-100 text-gray-800"
             }`}
           >
             {message.content}
           </div>
           {message.role === "user" && (
             <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center">
               <User className="w-5 h-5 text-white" />
             </div>
           )}
         </div>
       ))}
       {isLoading && (
         <div className="flex items-center space-x-2">
           <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
             <Bot className="w-5 h-5 text-blue-600" />
           </div>
           <div className="bg-gray-100 p-3 rounded-lg">
             <div className="flex space-x-2">
               <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
               <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
               <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
             </div>
           </div>
         </div>
       )}
       <div ref={messagesEndRef} />
     </div>

     <form onSubmit={handleSendMessage} className="p-4 border-t">
       <div className="flex space-x-2">
         <input
           type="file"
           ref={fileInputRef}
           onChange={handleFileUpload}
           className="hidden"
           accept=".pdf,.doc,.docx,.txt,.md"
         />
         <button
           type="button"
           onClick={() => fileInputRef.current?.click()}
           className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
           disabled={isUploading}
           title="Last opp dokument"
         >
           {isUploading ? (
             <Loader className="w-5 h-5 text-gray-500 animate-spin" />
           ) : (
             <Paperclip className="w-5 h-5 text-gray-500" />
           )}
         </button>
         <input
           type="text"
           value={inputMessage}
           onChange={(e) => setInputMessage(e.target.value)}
           placeholder="Skriv en melding..."
           className="flex-1 p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600"
           disabled={isLoading}
         />
         <button
           type="submit"
           disabled={isLoading || !inputMessage.trim()}
           className="p-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
         >
           <Send className="w-5 h-5" />
         </button>
       </div>
     </form>
   </div>
 )
}

export default FloatingChatWidget
