import { ChatArea } from '@/components/ChatArea'
import { Sidebar } from '@/components/Sidebar'

export default function App() {
  return (
    <div className="flex h-screen">
      <Sidebar />
      <ChatArea />
    </div>
  )
}
