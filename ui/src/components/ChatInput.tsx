import { cn } from '@/lib/utils'
import { Send } from 'lucide-react'
import { type KeyboardEvent, useState } from 'react'

interface ChatInputProps {
  onSend: (message: string) => void
  disabled?: boolean
}

export function ChatInput({ onSend, disabled }: ChatInputProps) {
  const [input, setInput] = useState('')

  const handleSend = () => {
    if (input.trim() && !disabled) {
      onSend(input.trim())
      setInput('')
    }
  }

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  return (
    <div className="border-t border-claude-border bg-claude-bg p-4">
      <div className="mx-auto max-w-3xl">
        <div className="relative flex items-end gap-2 rounded-2xl border border-claude-border bg-claude-bg-input p-2">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Message Claude..."
            disabled={disabled}
            rows={1}
            className={cn(
              'max-h-40 min-h-[44px] flex-1 resize-none bg-transparent px-3 py-2 text-claude-text placeholder-claude-text-muted outline-none',
              disabled && 'cursor-not-allowed opacity-50',
            )}
            style={{
              height: 'auto',
              minHeight: '44px',
            }}
          />
          <button
            type="button"
            onClick={handleSend}
            disabled={!input.trim() || disabled}
            className={cn(
              'flex h-10 w-10 shrink-0 items-center justify-center rounded-xl transition-colors',
              input.trim() && !disabled
                ? 'bg-claude-accent text-white hover:bg-claude-accent-hover'
                : 'bg-claude-border text-claude-text-muted',
            )}
          >
            <Send size={18} />
          </button>
        </div>
        <p className="mt-2 text-center text-xs text-claude-text-muted">
          Claude can make mistakes. Consider checking important information.
        </p>
      </div>
    </div>
  )
}
