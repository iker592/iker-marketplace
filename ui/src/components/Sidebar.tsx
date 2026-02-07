import { cn } from '@/lib/utils'
import { type Conversation, useChatStore } from '@/stores/useChatStore'
import { MessageSquarePlus, MessagesSquare } from 'lucide-react'

export function Sidebar() {
  const { conversations, activeConversationId, createConversation, setActiveConversation } =
    useChatStore()

  return (
    <aside className="flex h-full w-64 flex-col border-r border-claude-border bg-claude-bg">
      {/* New chat button */}
      <div className="p-3">
        <button
          type="button"
          onClick={createConversation}
          className="flex w-full items-center gap-2 rounded-lg border border-claude-border px-4 py-3 text-sm font-medium text-claude-text transition-colors hover:bg-claude-bg-light"
        >
          <MessageSquarePlus size={18} />
          New chat
        </button>
      </div>

      {/* Conversations list */}
      <div className="flex-1 overflow-y-auto px-2">
        <div className="mb-2 px-2 text-xs font-medium uppercase tracking-wider text-claude-text-muted">
          Conversations
        </div>
        <nav className="space-y-1">
          {conversations.map((conv) => (
            <ConversationItem
              key={conv.id}
              conversation={conv}
              isActive={conv.id === activeConversationId}
              onClick={() => setActiveConversation(conv.id)}
            />
          ))}
          {conversations.length === 0 && (
            <p className="px-2 py-4 text-center text-sm text-claude-text-muted">
              No conversations yet
            </p>
          )}
        </nav>
      </div>

      {/* Footer */}
      <div className="border-t border-claude-border p-3">
        <div className="flex items-center gap-2 text-sm text-claude-text-muted">
          <div className="h-8 w-8 rounded-full bg-claude-accent" />
          <span>Iker</span>
        </div>
      </div>
    </aside>
  )
}

function ConversationItem({
  conversation,
  isActive,
  onClick,
}: {
  conversation: Conversation
  isActive: boolean
  onClick: () => void
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm transition-colors',
        isActive
          ? 'bg-claude-bg-light text-claude-text'
          : 'text-claude-text-muted hover:bg-claude-bg-light hover:text-claude-text',
      )}
    >
      <MessagesSquare size={16} />
      <span className="truncate">{conversation.title}</span>
    </button>
  )
}
