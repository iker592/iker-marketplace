/**
 * Chat server using Claude Agent SDK
 *
 * To use Amazon Bedrock instead of Anthropic API:
 * 1. Set environment variable: CLAUDE_CODE_USE_BEDROCK=1
 * 2. Configure AWS credentials (via AWS CLI, env vars, or IAM role):
 *    - AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, or
 *    - AWS_PROFILE and AWS_REGION, or
 *    - IAM role (if running on EC2/Lambda)
 * 3. Ensure Claude models are available in your Bedrock region
 *
 * See: https://platform.claude.com/docs/en/agent-sdk/overview
 */
import { query } from '@anthropic-ai/claude-agent-sdk'
const SYSTEM_PROMPT = `You are a helpful assistant for the Iker Marketplace, a collection of plugins for Claude Code.

Here are the available plugins in the marketplace:

1. **typescript-dev** - TypeScript/React development standards
   - Stack: Bun, Vite, React, Tailwind CSS, shadcn/ui, Zustand, React Router, Vitest, Playwright, Biome
   - Use for: Creating React apps, components, tests, linting with Biome
   - Key commands: make setup, make ui, make test, make fix

2. **python-dev** - Python development standards
   - Stack: uv, FastAPI, FastMCP, pytest, ruff
   - Use for: Python projects, FastAPI services, MCP servers, testing with pytest
   - Key commands: make setup, make local, make test, make fix

3. **apple-notes** - Apple Notes integration
   - Allows reading, creating, and managing Apple Notes on macOS via AppleScript

4. **second-brain** - Knowledge management
   - Capture, organize, and retrieve knowledge from your second brain

5. **daily-todos** - Task management
   - Manage daily tasks and to-do lists

To install plugins, users can run:
- \`iker setup-local\` - Setup for current project (gitignored, personal)
- \`iker setup-global\` - Setup globally for all projects

Be helpful and concise. Answer questions about the plugins, their features, and how to use them.`
// Enable Bedrock if env var is set
// The Agent SDK automatically detects CLAUDE_CODE_USE_BEDROCK=1 from environment
const USE_BEDROCK = Bun.env.CLAUDE_CODE_USE_BEDROCK === '1'
if (USE_BEDROCK) {
  console.log('✓ Bedrock mode enabled (CLAUDE_CODE_USE_BEDROCK=1)')
} else {
  console.log('ℹ Using Anthropic API (set CLAUDE_CODE_USE_BEDROCK=1 to use Bedrock)')
}
const server = Bun.serve({
  port: 3001,
  async fetch(req) {
    const url = new URL(req.url)
    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    }
    // Handle preflight
    if (req.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders })
    }
    if (url.pathname === '/api/chat' && req.method === 'POST') {
      try {
        let body
        try {
          body = await req.json()
        } catch (parseError) {
          console.error('JSON parse error:', parseError)
          const text = await req.text()
          console.error('Request body:', text)
          return new Response(JSON.stringify({ error: 'Invalid JSON in request body' }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        }
        const messages = body?.messages || []
        // Build prompt from conversation history
        // Last message is the user's current question
        const lastMessage = messages[messages.length - 1]
        if (!lastMessage || lastMessage.role !== 'user') {
          return new Response(JSON.stringify({ error: 'Last message must be from user' }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        }
        // Build context from previous messages
        const contextMessages = messages.slice(0, -1)
        let prompt = lastMessage.content
        if (contextMessages.length > 0) {
          const context = contextMessages
            .map((m) => `${m.role === 'user' ? 'User' : 'Assistant'}: ${m.content}`)
            .join('\n\n')
          prompt = `${context}\n\nUser: ${lastMessage.content}`
        }
        // Create streaming response using Agent SDK
        const encoder = new TextEncoder()
        const readable = new ReadableStream({
          async start(controller) {
            try {
              const agentQuery = query({
                prompt,
                options: {
                  systemPrompt: SYSTEM_PROMPT,
                  allowedTools: [], // No tools for simple chat
                  includePartialMessages: true, // Enable streaming
                  ...(USE_BEDROCK &&
                    {
                      // Bedrock is enabled via CLAUDE_CODE_USE_BEDROCK=1 env var
                      // AWS credentials should be configured via AWS SDK defaults
                    }),
                },
              })
              for await (const message of agentQuery) {
                if (
                  message.type === 'stream_event' &&
                  message.event.type === 'content_block_delta'
                ) {
                  // Stream partial text deltas (primary streaming path)
                  const delta = message.event.delta
                  if (delta.type === 'text_delta') {
                    const data = JSON.stringify({ text: delta.text })
                    controller.enqueue(encoder.encode(`data: ${data}\n\n`))
                  }
                } else if (message.type === 'result') {
                  // Done — don't emit result.result since it duplicates the streamed text
                  controller.enqueue(encoder.encode('data: [DONE]\n\n'))
                  controller.close()
                  return
                }
                // Skip 'assistant' messages — they contain the full text already
                // streamed via stream_event deltas above
              }
              controller.enqueue(encoder.encode('data: [DONE]\n\n'))
              controller.close()
            } catch (error) {
              console.error('Stream error:', error)
              const err = error
              const raw = err?.message ?? ''
              const msg = raw || 'An error occurred while generating the response.'
              controller.enqueue(encoder.encode(`data: ${JSON.stringify({ text: msg })}\n\n`))
              controller.enqueue(encoder.encode('data: [DONE]\n\n'))
              controller.close()
            }
          },
        })
        return new Response(readable, {
          headers: {
            ...corsHeaders,
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            Connection: 'keep-alive',
          },
        })
      } catch (error) {
        console.error('API error:', error)
        const err = error
        const status = err?.status ?? 500
        const rawMessage = String(err?.message ?? '')
        const userMessage = rawMessage || 'Internal server error'
        return new Response(JSON.stringify({ error: userMessage }), {
          status,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }
    return new Response('Not found', { status: 404, headers: corsHeaders })
  },
})
console.log(`Server running at http://localhost:${server.port}`)
