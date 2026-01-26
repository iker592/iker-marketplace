import { Bot, User } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { Message as MessageType } from '@/stores/useChatStore'

interface MessageProps {
  message: MessageType
}

export function Message({ message }: MessageProps) {
  const isAssistant = message.role === 'assistant'

  return (
    <div
      className={cn('flex gap-4 px-4 py-6', isAssistant ? 'bg-claude-bg-light' : 'bg-claude-bg')}
    >
      <div
        className={cn(
          'flex h-8 w-8 shrink-0 items-center justify-center rounded-full',
          isAssistant ? 'bg-claude-accent text-white' : 'bg-claude-border text-claude-text'
        )}
      >
        {isAssistant ? <Bot size={18} /> : <User size={18} />}
      </div>
      <div className="flex-1 space-y-2">
        <div className="text-sm font-medium text-claude-text">
          {isAssistant ? 'Claude' : 'You'}
        </div>
        <div className="prose prose-invert max-w-none text-claude-text">
          <p className="whitespace-pre-wrap">{message.content}</p>
        </div>
      </div>
    </div>
  )
}
