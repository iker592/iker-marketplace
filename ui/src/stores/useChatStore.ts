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
  addMessage: (conversationId: string, role: 'user' | 'assistant', content: string) => void
  getActiveConversation: () => Conversation | null
}

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
          : conv
      ),
    }))
  },

  getActiveConversation: () => {
    const state = get()
    return state.conversations.find((c) => c.id === state.activeConversationId) ?? null
  },
}))
