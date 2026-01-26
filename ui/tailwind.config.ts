import type { Config } from 'tailwindcss'

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Claude.ai color palette
        claude: {
          bg: '#2D2B2B',
          'bg-light': '#3D3B3B',
          'bg-input': '#1A1919',
          accent: '#D97706',
          'accent-hover': '#B45309',
          text: '#E5E5E5',
          'text-muted': '#9CA3AF',
          border: '#4B4949',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
  plugins: [],
} satisfies Config
