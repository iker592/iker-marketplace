import { Sidebar } from '@/components/Sidebar'
import { ChatArea } from '@/components/ChatArea'

export default function App() {
  return (
    <div className="flex h-screen">
      <Sidebar />
      <ChatArea />
    </div>
  )
}
