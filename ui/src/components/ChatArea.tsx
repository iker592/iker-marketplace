import { useChatStore } from '@/stores/useChatStore'
import { Sparkles } from 'lucide-react'
import { useEffect, useRef } from 'react'
import { ChatInput } from './ChatInput'
import { Message } from './Message'

export function ChatArea() {
  const { getActiveConversation, sendMessage, isLoading } = useChatStore()
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const conversation = getActiveConversation()

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [conversation?.messages])

  const handleSend = async (content: string) => {
    await sendMessage(content)
  }

  return (
    <main className="flex flex-1 flex-col bg-claude-bg">
      {/* Messages area */}
      <div className="flex-1 overflow-y-auto">
        {!conversation || conversation.messages.length === 0 ? (
          <EmptyState />
        ) : (
          <div className="mx-auto max-w-3xl">
            {conversation.messages.map((message) => (
              <Message key={message.id} message={message} />
            ))}
            <div ref={messagesEndRef} />
          </div>
        )}
      </div>

      {/* Input area */}
      <ChatInput onSend={handleSend} disabled={isLoading} />
    </main>
  )
}

function EmptyState() {
  return (
    <div className="flex h-full flex-col items-center justify-center px-4">
      <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-claude-accent">
        <Sparkles size={32} className="text-white" />
      </div>
      <h1 className="mb-2 text-2xl font-semibold text-claude-text">How can I help you today?</h1>
      <p className="max-w-md text-center text-claude-text-muted">
        Ask me about the Iker Marketplace plugins - typescript-dev, python-dev, apple-notes, and
        more!
      </p>
    </div>
  )
}
