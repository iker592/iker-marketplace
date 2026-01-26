import { useEffect, useRef } from 'react'
import { Sparkles } from 'lucide-react'
import { useChatStore } from '@/stores/useChatStore'
import { Message } from './Message'
import { ChatInput } from './ChatInput'

export function ChatArea() {
  const { activeConversationId, getActiveConversation, addMessage, createConversation } =
    useChatStore()
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const conversation = getActiveConversation()

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [conversation?.messages])

  const handleSend = (content: string) => {
    let convId = activeConversationId
    if (!convId) {
      convId = createConversation()
    }

    // Add user message
    addMessage(convId, 'user', content)

    // Simulate assistant response
    setTimeout(() => {
      addMessage(
        convId!,
        'assistant',
        "Hello! I'm Claude, an AI assistant. I'm here to help you with any questions or tasks you might have. How can I assist you today?"
      )
    }, 1000)
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
      <ChatInput onSend={handleSend} />
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
        I'm Claude, an AI assistant made by Anthropic. I can help you with analysis, writing, code,
        math, and more.
      </p>
    </div>
  )
}
