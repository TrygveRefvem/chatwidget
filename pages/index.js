import FloatingChatWidget from "../components/ChatWidget/FloatingChatWidget"

export default function Home() {
 return (
   <div className="min-h-screen bg-gray-100 p-4">
     <h1 className="text-2xl font-bold mb-4">Azure OpenAI Chat Widget Demo</h1>
     <FloatingChatWidget />
   </div>
 )
}
