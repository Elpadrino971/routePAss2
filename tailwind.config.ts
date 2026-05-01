import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: ['./src/**/*.{ts,tsx,js,jsx,mdx}'],
  theme: {
    extend: {
      colors: {
        rp: {
          black: '#08080D',
          dark: '#0F0F18',
          'dark-2': '#16161F',
          border: '#1E1E2E',
          gold: '#C9A84C',
          'gold-light': '#E8C96A',
          'gold-muted': '#8B6E2A',
          white: '#F5F0E8',
          gray: '#6B6B7B',
          success: '#22C55E',
          danger: '#EF4444',
          warning: '#F59E0B',
          info: '#3B82F6',
        },
      },
      fontFamily: {
        display: ['var(--font-display)', 'serif'],
        body: ['var(--font-body)', 'sans-serif'],
        mono: ['var(--font-mono)', 'monospace'],
      },
      borderRadius: {
        rp: '20px',
        'rp-btn': '12px',
        'rp-input': '8px',
      },
      boxShadow: {
        rp: '0 8px 32px rgba(0, 0, 0, 0.4)',
        'rp-gold': '0 8px 24px rgba(201, 168, 76, 0.25)',
      },
      keyframes: {
        'pulse-dot': {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%': { opacity: '0.6', transform: 'scale(1.4)' },
        },
        'fade-up': {
          '0%': { opacity: '0', transform: 'translateY(8px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-400px 0' },
          '100%': { backgroundPosition: '400px 0' },
        },
      },
      animation: {
        'pulse-dot': 'pulse-dot 1.6s ease-in-out infinite',
        'fade-up': 'fade-up 0.35s ease-out',
        shimmer: 'shimmer 1.6s linear infinite',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
};

export default config;
