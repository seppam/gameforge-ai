# GameForge AI

Transform natural language prompts into interactive, fully playable 2D web games in real-time.

## Overview

GameForge AI is a no-code web platform that leverages a multi-agent AI orchestration pipeline to generate 2D web games from natural language descriptions. Built with Next.js, Phaser 3, and Supabase.

## Features

- **Zero-Code Game Creation**: Type a description, get a playable game in under 30 seconds
- **Conversational Iteration**: Chat with AI to tweak physics, difficulty, colors, and more
- **Autonomous Self-Healing**: Runtime errors caught and fixed automatically (max 3 cycles)
- **Zero-Cost Assets**: Curated Kenney CC0 sprites + procedural jsfxr audio
- **Frictionless Distribution**: Public share links, ZIP export, GitHub sync

## Tech Stack

- **Frontend**: Next.js 15, React 19, TypeScript, Tailwind CSS, shadcn/ui
- **Game Engine**: Phaser 3.80+ (Arcade Physics)
- **Audio**: jsfxr (Procedural Web Audio)
- **Database**: Supabase (PostgreSQL 15+, Auth, RLS)
- **AI**: Vercel AI SDK, Multi-agent pipeline (Spec → Asset → Coder → Debug)

## Project Structure

```
gameforge-ai/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Authentication routes
│   ├── (dashboard)/       # Dashboard & settings
│   ├── admin/             # Admin portal
│   ├── studio/            # Game builder studio
│   ├── play/              # Public game player
│   └── api/               # API routes
├── components/            # React components
│   ├── studio/           # Studio-specific components
│   ├── admin/            # Admin components
│   ├── layout/           # Layout components
│   ├── dashboard/        # Dashboard components
│   └── ui/               # shadcn/ui components
├── lib/                  # Utilities & libraries
│   ├── ai/              # AI agents & orchestration
│   ├── assets/          # Asset catalog & presets
│   ├── sandbox/         # Sandbox runner template
│   ├── export/          # Export utilities
│   └── supabase/        # Supabase clients
├── types/               # TypeScript types
├── public/              # Static assets
│   └── assets/sprites/  # Kenney sprite bank
├── docs/                # Project documentation
│   ├── PRD.md
│   ├── Architecture.md
│   ├── Schema.md
│   ├── Sitemap.md
│   ├── Rules.md
│   ├── Design.md
│   └── Proposal.md
└── supabase/            # Database migrations
    └── migrations/
```

## Documentation

All project documentation is in the `/docs` folder:

- **PRD.md** — Product Requirements Document
- **Architecture.md** — System architecture & data flow
- **Schema.md** — Database schema & RLS policies
- **Sitemap.md** — Site map & navigation
- **Rules.md** — Coding standards & limitations
- **Design.md** — UI/UX design system
- **Proposal.md** — Business model & monetization

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account
- LLM API keys (Anthropic, OpenAI, Google, or DeepSeek)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd gameforge-ai
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env.local
```

4. Update `.env.local` with your credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# LLM Provider API Keys
ANTHROPIC_API_KEY=your_anthropic_key
OPENAI_API_KEY=your_openai_key
GOOGLE_GENERATIVE_AI_API_KEY=your_google_key
DEEPSEEK_API_KEY=your_deepseek_key
```

5. Run database migrations:
```bash
npm run db:migrate
```

6. Start the development server:
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Development

### Branch Strategy

- `main` — Production-ready, protected branch
- `feat/[name]` — Feature branches
- `fix/[name]` — Bug fix branches

### Daily Sync

Team sync at **16:00 WIB** to verify cross-engineer integration points.

## Team

- 3 Full-Stack & AI Engineers
- 8-Day Development Sprint

## License

[MIT](LICENSE)
