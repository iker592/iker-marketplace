import { create } from 'zustand'

export interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

export interface Conversation {
  id: string
  title: string
  messages: Message[]
  createdAt: Date
}

interface ChatState {
  conversations: Conversation[]
  activeConversationId: string | null
  isLoading: boolean
  createConversation: () => string
  setActiveConversation: (id: string) => void
  addMessage: (conversationId: string, role: 'user' | 'assistant', content: string) => string
  updateMessage: (conversationId: string, messageId: string, content: string) => void
  appendToMessage: (conversationId: string, messageId: string, text: string) => void
  getActiveConversation: () => Conversation | null
  setLoading: (loading: boolean) => void
  sendMessage: (content: string) => Promise<void>
}

const API_URL = 'http://localhost:3001/api/chat'

export const useChatStore = create<ChatState>((set, get) => ({
  conversations: [],
  activeConversationId: null,
  isLoading: false,

  createConversation: () => {
    const newConversation: Conversation = {
      id: crypto.randomUUID(),
      title: 'New conversation',
      messages: [],
      createdAt: new Date(),
    }
    set((state) => ({
      conversations: [newConversation, ...state.conversations],
      activeConversationId: newConversation.id,
    }))
    return newConversation.id
  },

  setActiveConversation: (id) => {
    set({ activeConversationId: id })
  },

  addMessage: (conversationId, role, content) => {
    const newMessage: Message = {
      id: crypto.randomUUID(),
      role,
      content,
      timestamp: new Date(),
    }
    set((state) => ({
      conversations: state.conversations.map((conv) =>
        conv.id === conversationId
          ? {
              ...conv,
              messages: [...conv.messages, newMessage],
              title:
                conv.messages.length === 0 && role === 'user'
                  ? content.slice(0, 30) + (content.length > 30 ? '...' : '')
                  : conv.title,
            }
          : conv,
      ),
    }))
    return newMessage.id
  },

  updateMessage: (conversationId, messageId, content) => {
    set((state) => ({
      conversations: state.conversations.map((conv) =>
        conv.id === conversationId
          ? {
              ...conv,
              messages: conv.messages.map((msg) =>
                msg.id === messageId ? { ...msg, content } : msg,
              ),
            }
          : conv,
      ),
    }))
  },

  appendToMessage: (conversationId, messageId, text) => {
    set((state) => ({
      conversations: state.conversations.map((conv) =>
        conv.id === conversationId
          ? {
              ...conv,
              messages: conv.messages.map((msg) =>
                msg.id === messageId ? { ...msg, content: msg.content + text } : msg,
              ),
            }
          : conv,
      ),
    }))
  },

  getActiveConversation: () => {
    const state = get()
    return state.conversations.find((c) => c.id === state.activeConversationId) ?? null
  },

  setLoading: (loading) => {
    set({ isLoading: loading })
  },

  sendMessage: async (content) => {
    const state = get()
    let convId = state.activeConversationId

    if (!convId) {
      convId = get().createConversation()
    }

    // Add user message
    get().addMessage(convId, 'user', content)

    // Get conversation for API
    const conversation = get().conversations.find((c) => c.id === convId)
    if (!conversation) return

    // Prepare messages for API (exclude the empty assistant message we're about to add)
    const apiMessages = conversation.messages.map((m) => ({
      role: m.role,
      content: m.content,
    }))

    // Add empty assistant message that we'll stream into
    const assistantMessageId = get().addMessage(convId, 'assistant', '')

    set({ isLoading: true })

    try {
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ messages: apiMessages }),
      })

      if (!response.ok) {
        let message = 'API request failed'
        try {
          const body = (await response.json()) as { error?: string }
          if (body?.error) message = body.error
        } catch {
          // use default message
        }
        throw new Error(message)
      }

      const reader = response.body?.getReader()
      if (!reader) throw new Error('No reader available')

      const decoder = new TextDecoder()

      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        const chunk = decoder.decode(value)
        const lines = chunk.split('\n')

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6)
            if (data === '[DONE]') break

            try {
              const parsed = JSON.parse(data)
              if (parsed.text) {
                if (convId) get().appendToMessage(convId, assistantMessageId, parsed.text)
              }
            } catch {
              // Ignore parse errors for incomplete chunks
            }
          }
        }
      }
    } catch (error) {
      console.error('Error sending message:', error)
      const message =
        error instanceof Error
          ? error.message
          : 'Sorry, I encountered an error. Please make sure the server is running on port 3001.'
      get().updateMessage(convId, assistantMessageId, message)
    } finally {
      set({ isLoading: false })
    }
  },
}))
