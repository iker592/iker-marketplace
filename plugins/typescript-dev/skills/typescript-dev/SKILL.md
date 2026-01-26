---
name: TypeScript Development
description: This skill should be used when the user asks to "create a React app", "add a component", "write tests", "run vitest", "fix linting", "use bun", or works on any TypeScript/React code. Covers Bun, Vite, React, Tailwind, shadcn/ui, Zustand, React Router, Vitest, Playwright, and Biome.
---

# TypeScript/React Development Standards

Standards for TypeScript/React development in this organization. All projects use Bun for package management, Vite for building, React with TypeScript, Tailwind CSS with shadcn/ui for styling, Zustand for state, React Router for routing, Vitest for unit tests, Playwright for E2E tests, and Biome for linting/formatting.

## Core Requirements

- **TypeScript 5+** - Strict mode enabled
- **Bun** - Package management (not npm, yarn, or pnpm)
- **Vite** - Build tool and dev server
- **Biome** - Linting and formatting (not ESLint/Prettier)
- **Vitest** - Unit testing (not Jest)

## Bun Commands

### Project Setup

```bash
bun create vite project-name --template react-ts  # Create new project
cd project-name
bun install                                        # Install dependencies
bun run dev                                        # Start dev server
```

### Dependency Management

```bash
bun add react-router-dom           # Add dependency
bun add -d vitest @testing-library/react  # Add dev dependency
bun remove package-name            # Remove dependency
bun update                         # Update all dependencies
bun run build                      # Build for production
```

### package.json Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:e2e": "playwright test",
    "lint": "biome check .",
    "fix": "biome check --write ."
  }
}
```

## Vite Configuration

### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    open: true,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    css: true,
  },
})
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

## React Patterns

### Component Structure

```typescript
// src/components/Button.tsx
import { type ReactNode, type ButtonHTMLAttributes } from 'react'
import { cn } from '@/lib/utils'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'destructive'
  size?: 'sm' | 'md' | 'lg'
  children: ReactNode
}

export function Button({
  variant = 'primary',
  size = 'md',
  className,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded-md font-medium transition-colors',
        {
          'bg-blue-600 text-white hover:bg-blue-700': variant === 'primary',
          'bg-gray-200 text-gray-900 hover:bg-gray-300': variant === 'secondary',
          'bg-red-600 text-white hover:bg-red-700': variant === 'destructive',
        },
        {
          'px-3 py-1.5 text-sm': size === 'sm',
          'px-4 py-2 text-base': size === 'md',
          'px-6 py-3 text-lg': size === 'lg',
        },
        className
      )}
      {...props}
    >
      {children}
    </button>
  )
}
```

### Custom Hooks

```typescript
// src/hooks/useLocalStorage.ts
import { useState, useEffect } from 'react'

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch {
      return initialValue
    }
  })

  useEffect(() => {
    window.localStorage.setItem(key, JSON.stringify(storedValue))
  }, [key, storedValue])

  return [storedValue, setStoredValue] as const
}
```

### Error Boundary

```typescript
// src/components/ErrorBoundary.tsx
import { Component, type ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? <div>Something went wrong.</div>
    }
    return this.props.children
  }
}
```

## Tailwind CSS + shadcn/ui

### Setup shadcn/ui

```bash
bunx --bun shadcn@latest init
bunx --bun shadcn@latest add button card input dialog
```

### tailwind.config.ts

```typescript
import type { Config } from 'tailwindcss'

export default {
  darkMode: ['class'],
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
} satisfies Config
```

### Using shadcn/ui Components

```typescript
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'

export function LoginForm() {
  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>Login</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <Input type="email" placeholder="Email" />
        <Input type="password" placeholder="Password" />
        <Button className="w-full">Sign In</Button>
      </CardContent>
    </Card>
  )
}
```

## Zustand State Management

### Creating a Store

```typescript
// src/stores/useAuthStore.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface User {
  id: string
  email: string
  name: string
}

interface AuthState {
  user: User | null
  isAuthenticated: boolean
  login: (user: User) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      login: (user) => set({ user, isAuthenticated: true }),
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    { name: 'auth-storage' }
  )
)
```

### Using the Store

```typescript
import { useAuthStore } from '@/stores/useAuthStore'

export function UserProfile() {
  const { user, logout } = useAuthStore()

  if (!user) return null

  return (
    <div>
      <p>Welcome, {user.name}</p>
      <button onClick={logout}>Logout</button>
    </div>
  )
}
```

### Store with Async Actions

```typescript
// src/stores/useItemsStore.ts
import { create } from 'zustand'

interface Item {
  id: string
  name: string
}

interface ItemsState {
  items: Item[]
  loading: boolean
  error: string | null
  fetchItems: () => Promise<void>
  addItem: (name: string) => Promise<void>
}

export const useItemsStore = create<ItemsState>((set, get) => ({
  items: [],
  loading: false,
  error: null,

  fetchItems: async () => {
    set({ loading: true, error: null })
    try {
      const response = await fetch('/api/items')
      const items = await response.json()
      set({ items, loading: false })
    } catch (error) {
      set({ error: 'Failed to fetch items', loading: false })
    }
  },

  addItem: async (name) => {
    try {
      const response = await fetch('/api/items', {
        method: 'POST',
        body: JSON.stringify({ name }),
      })
      const newItem = await response.json()
      set({ items: [...get().items, newItem] })
    } catch (error) {
      set({ error: 'Failed to add item' })
    }
  },
}))
```

## React Router

### Router Setup

```typescript
// src/main.tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './index.css'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </StrictMode>
)
```

### Route Configuration

```typescript
// src/App.tsx
import { Routes, Route, Navigate } from 'react-router-dom'
import { Layout } from '@/components/Layout'
import { Home } from '@/pages/Home'
import { Dashboard } from '@/pages/Dashboard'
import { Login } from '@/pages/Login'
import { NotFound } from '@/pages/NotFound'
import { useAuthStore } from '@/stores/useAuthStore'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated)
  return isAuthenticated ? children : <Navigate to="/login" replace />
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />
        <Route path="login" element={<Login />} />
        <Route
          path="dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  )
}
```

### Navigation and Params

```typescript
import { useNavigate, useParams, useSearchParams } from 'react-router-dom'

export function ItemDetail() {
  const { itemId } = useParams<{ itemId: string }>()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()

  const tab = searchParams.get('tab') ?? 'overview'

  return (
    <div>
      <h1>Item {itemId}</h1>
      <button onClick={() => navigate(-1)}>Back</button>
      <button onClick={() => navigate('/dashboard')}>Dashboard</button>
    </div>
  )
}
```

## Vitest Unit Testing

### Test Setup

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

afterEach(() => {
  cleanup()
})
```

### Component Tests

```typescript
// src/components/Button.test.tsx
import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from './Button'

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    await userEvent.click(screen.getByText('Click me'))

    expect(handleClick).toHaveBeenCalledOnce()
  })

  it('applies variant classes', () => {
    render(<Button variant="destructive">Delete</Button>)
    expect(screen.getByText('Delete')).toHaveClass('bg-red-600')
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Disabled</Button>)
    expect(screen.getByText('Disabled')).toBeDisabled()
  })
})
```

### Hook Tests

```typescript
// src/hooks/useCounter.test.ts
import { describe, it, expect } from 'vitest'
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter())
    expect(result.current.count).toBe(0)
  })

  it('initializes with provided value', () => {
    const { result } = renderHook(() => useCounter(10))
    expect(result.current.count).toBe(10)
  })

  it('increments count', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })
})
```

### Mocking

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { ItemList } from './ItemList'

// Mock fetch
global.fetch = vi.fn()

describe('ItemList', () => {
  beforeEach(() => {
    vi.resetAllMocks()
  })

  it('displays items after loading', async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => [{ id: '1', name: 'Item 1' }],
    } as Response)

    render(<ItemList />)

    await waitFor(() => {
      expect(screen.getByText('Item 1')).toBeInTheDocument()
    })
  })

  it('displays error on fetch failure', async () => {
    vi.mocked(fetch).mockRejectedValueOnce(new Error('Network error'))

    render(<ItemList />)

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })
  })
})
```

## Playwright E2E Testing

### Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  ],
  webServer: {
    command: 'bun run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

### E2E Tests

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login')

    await page.fill('input[type="email"]', 'user@example.com')
    await page.fill('input[type="password"]', 'password123')
    await page.click('button[type="submit"]')

    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome')).toBeVisible()
  })

  test('shows error on invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.fill('input[type="email"]', 'wrong@example.com')
    await page.fill('input[type="password"]', 'wrongpassword')
    await page.click('button[type="submit"]')

    await expect(page.getByText('Invalid credentials')).toBeVisible()
  })
})
```

### Page Objects

```typescript
// e2e/pages/LoginPage.ts
import { type Page, type Locator } from '@playwright/test'

export class LoginPage {
  readonly page: Page
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    this.page = page
    this.emailInput = page.locator('input[type="email"]')
    this.passwordInput = page.locator('input[type="password"]')
    this.submitButton = page.locator('button[type="submit"]')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }
}

// Usage in test
test('login flow', async ({ page }) => {
  const loginPage = new LoginPage(page)
  await loginPage.goto()
  await loginPage.login('user@example.com', 'password123')
  await expect(page).toHaveURL('/dashboard')
})
```

## Biome

### Configuration

```json
// biome.json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noForEach": "warn"
      },
      "style": {
        "noNonNullAssertion": "warn"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "asNeeded"
    }
  },
  "files": {
    "ignore": ["node_modules", "dist", ".next"]
  }
}
```

### Commands

```bash
bun run lint           # Check for issues
bun run fix            # Auto-fix issues and format
bunx @biomejs/biome check --write .  # Direct command
```

## Standard Makefile

All projects must have a Makefile with these targets:

```makefile
.PHONY: setup ui build test test-ui e2e fix lint preview clean all

setup:
	curl -fsSL https://bun.sh/install | bash
	bun install
	bunx --bun playwright install

ui:
	bun run dev

build:
	bun run build

test:
	bun run test

test-ui:
	bun run test:ui

e2e:
	bun run test:e2e

fix:
	bun run fix

lint:
	bun run lint

preview:
	bun run preview

clean:
	rm -rf node_modules dist .vite

all: fix test build
```

### Target Usage

| Target | When to Use |
|--------|-------------|
| `make setup` | First time cloning the repo |
| `make ui` | Start development server |
| `make build` | Build for production |
| `make test` | Run unit tests |
| `make test-ui` | Run tests with Vitest UI |
| `make e2e` | Run Playwright E2E tests |
| `make fix` | Before committing - fixes linting and formatting |
| `make lint` | Check for linting issues without fixing |
| `make preview` | Preview production build locally |
| `make clean` | Remove build artifacts |
| `make all` | Before pushing - runs fix, test, build |

## Project Structure

Typical project layout:

```
project-name/
├── biome.json
├── index.html
├── Makefile
├── package.json
├── playwright.config.ts
├── README.md
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
├── public/
├── e2e/
│   ├── auth.spec.ts
│   └── pages/
│       └── LoginPage.ts
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── index.css
    ├── vite-env.d.ts
    ├── components/
    │   ├── ui/            # shadcn/ui components
    │   ├── Layout.tsx
    │   └── Button.tsx
    ├── hooks/
    │   └── useLocalStorage.ts
    ├── lib/
    │   └── utils.ts       # cn() helper
    ├── pages/
    │   ├── Home.tsx
    │   ├── Dashboard.tsx
    │   └── Login.tsx
    ├── stores/
    │   └── useAuthStore.ts
    └── test/
        └── setup.ts
```

## Key Rules

1. **Never use npm/yarn/pnpm** - Always Bun
2. **Never use Jest** - Always Vitest
3. **Never use ESLint/Prettier** - Always Biome
4. **Always have Makefile** - With standard targets
5. **TypeScript strict mode** - Always enabled
6. **Run `make fix` before committing** - Keep code clean
7. **Run `make all` before pushing** - Ensure everything passes
