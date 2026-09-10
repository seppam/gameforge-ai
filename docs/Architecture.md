# System Architecture — GameForge AI

## 1. System Overview & Architectural Topology

GameForge AI employs a modular, decoupled architecture separating the Next.js presentation and orchestration layer from the sandboxed game execution runtime and external LLM inference providers. It features an automated resilient fallback pipeline that seamlessly shifts tasks from credit-exhausted models (e.g., Claude 3.5/3.7 Sonnet) to cost-effective alternatives (e.g., Google Gemini 2.0 Flash) without breaking user gameplay sessions.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                   CLIENT BROWSER                                       │
│  ┌────────────────────────────────────────┐  ┌──────────────────────────────────────┐  │
│  │       Split-Screen Studio (Next.js)    │  │       Sandboxed Game Runner (iframe) │  │
│  │  - Chat Dialogue & Prompt Stream       │  │  - Phaser 3 Runtime (Arcade Engine) │  │
│  │  - Monaco Editor (Code View/Diff)      │  │  - jsfxr Web Audio Synthesizer       │  │
│  │  - Stage Indicator & Version History   │  │  - postMessage Error Bridge          │  │
│  │  - Graceful Fallback Notification Toast│  │                                      │  │
│  └───────────────────▲────────────────────┘  └──────────────────▲───────────────────┘  │
└──────────────────────┼──────────────────────────────────────────┼──────────────────────┘
                       │ HTTPS / Server Actions / SSE             │ postMessage (window)
┌──────────────────────▼──────────────────────────────────────────┴──────────────────────┐
│                              NEXT.JS APP RUNTIME (BACKEND)                             │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Edge Middleware: Route Guards & Admin RBAC Enforcement (/admin/*)                │  │
│  └──────────────────────────────────────▲───────────────────────────────────────────┘  │
│                                         │                                              │
│  ┌────────────────────────┐  ┌──────────▼─────────────┐  ┌──────────────────────────┐  │
│  │   LLM Provider Router  │  │ Multi-Agent Engine     │  │   Export & Sync Engine   │  │
│  │   - Primary Engine     │  │  1. Spec Agent (LLM)   │  │   - ZIP Bundle Builder   │  │
│  │     (Claude Sonnet)    │  │  2. Asset Mapper (Det) │  │   - GitHub REST API Push │  │
│  │   - Auto Fallback Hub  │  │  3. Coder Agent (LLM)  │  │   - Static Play URL Gen  │  │
│  │     (Gemini 2.0 Flash) │  │  4. Self-Heal Debugger │  │                          │  │
│  │   - Quota/429 Trapper  │  │     (LLM, conditional) │  │                          │  │
│  └───────────▲────────────┘  └───────────▲────────────┘  └────────────▲─────────────┘  │
└──────────────┼───────────────────────────┼────────────────────────────┼────────────────┘
               │                           │                            │
┌──────────────▼───────────────────────────▼────────────────────────────▼────────────────┐
│                             DATABASE & INFRASTRUCTURE                                  │
│  ┌───────────────────────────────────┐      ┌───────────────────────────────────────┐  │
│  │        Supabase PostgreSQL        │      │          Cloudflare CDN / S3          │  │
│  │  - User Auth & Role RBAC          │      │  - Curated Kenney Asset Sprites Bank  │  │
│  │  - Dynamic LLM Config & Fallbacks │      │  - Phaser 3 & jsfxr CDN Bundles       │  │
│  │  - Games, Prompts & Code Snapshots│      └───────────────────────────────────────┘  │
│  │  - Immutable Version Snapshots    │                                                 │
│  └───────────────────────────────────┘                                                 │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

**Key Cost Optimization:** Asset Mapper is **deterministic** (zero LLM cost) using keyword matching against curated Kenney Catalog. Only Spec Agent, Coder Agent, and conditional Debug Agent invoke LLMs.

---

## 2. Technology Stack

| Layer | Technology | Selection Rationale |
| :--- | :--- | :--- |
| **Frontend Framework** | Next.js 14/15 (App Router, React 18/19, TypeScript) | Server components, robust streaming, unified API routes and server actions. |
| **Edge Middleware** | Next.js Edge Middleware (`middleware.ts`) | Sub-millisecond JWT authentication and strict RBAC verification for `/admin/*`. |
| **Styling & UI** | Tailwind CSS + shadcn/ui + Radix UI + Lucide Icons | High polish, zero-friction accessible component design system. |
| **Code Editor** | Monaco Editor / `@monaco-editor/react` | Industry-standard code viewing, syntax highlighting, diff inspection. |
| **Game Engine** | Phaser 3.80+ (via CDN in Sandbox) | Fast 2D WebGL/Canvas rendering, robust Arcade Physics, lightweight footprint. |
| **Audio Engine** | jsfxr (Procedural Web Audio) | Zero storage cost, instant procedural 8-bit sound generation from JSON configs. |
| **Database & Auth** | Supabase (PostgreSQL 15+, Supabase Auth, Row Level Security) | Built-in Auth, relational schema, JSONB versioning, high security. |
| **AI Orchestration** | Vercel AI SDK (`ai` package) + Custom Agent Harness | Standardized streaming, easy provider switching, schema validation via Zod. |
| **LLM Providers** | Anthropic Claude 3.5/3.7, DeepSeek V3, OpenAI GPT-4o, Gemini 2.0 Flash | Configurable dynamic routing with automated primary-to-fallback circuit breaker. |
| **Rate Limiting** | Upstash Redis (`@upstash/ratelimit`) | Edge-compatible sliding-window rate limiting to prevent API budget abuse. |

---

## 3. Directory & Folder Structure

```
gameforge-ai/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (dashboard)/
│   │   ├── dashboard/page.tsx
│   │   └── settings/page.tsx
│   ├── admin/
│   │   └── llm-config/page.tsx          # Dynamic Provider switcher & API Keys (RBAC Protected)
│   ├── studio/
│   │   └── [gameId]/page.tsx            # Split-Screen Studio Builder
│   ├── play/
│   │   └── [slug]/page.tsx              # Standalone Public Play view
│   ├── api/
│   │   ├── generate/route.ts            # Multi-agent prompt pipeline endpoint
│   │   ├── patch/route.ts               # Context-aware chat modification endpoint
│   │   ├── debug/route.ts               # Self-healing runtime bug fixer
│   │   ├── export/
│   │   │   ├── zip/route.ts             # Standalone ZIP bundler
│   │   │   └── github/route.ts          # GitHub repo sync endpoint
│   │   └── admin/llm/route.ts           # Admin LLM configuration management
│   ├── layout.tsx
│   └── page.tsx                         # Landing Page & Public Showcase
├── middleware.ts                        # Edge route guard for /admin, /studio, /dashboard
├── components/
│   ├── layout/
│   │   ├── AppShell.tsx                 # Sidebar + header shell
│   │   ├── Sidebar.tsx                  # Collapsible navigation + project tree
│   │   └── Header.tsx                   # Top bar with title, status, actions
│   ├── dashboard/
│   │   ├── HeroSection.tsx              # Greeting + prompt input
│   │   ├── GameCard.tsx                 # Latest game card
│   │   └── ExamplePrompts.tsx           # "Try an Example" section
│   ├── studio/
│   │   ├── ChatPanel.tsx                # Left panel: message history & prompt input
│   │   ├── SandboxCanvas.tsx            # Right panel: sandboxed iframe runner
│   │   ├── CodeViewer.tsx               # Monaco editor preview & code diff
│   │   ├── PipelineStepper.tsx          # Spec -> Asset -> Code -> Running progress
│   │   ├── ConsoleDrawer.tsx            # Error capture and debug logs
│   │   ├── FallbackAlertToast.tsx       # Live alert when provider transitions to Gemini backup
│   │   └── PublishModal.tsx             # Share link, ZIP export, GitHub push
│   ├── admin/
│   │   └── ModelSelectorForm.tsx        # LLM primary + fallback assignment controls
│   └── ui/                              # shadcn/ui shared components
├── lib/
│   ├── ai/
│   │   ├── agents/
│   │   │   ├── specAgent.ts             # Prompt -> Structured Game Spec (LLM)
│   │   │   ├── assetMapper.ts           # Spec entities -> Kenney Assets + jsfxr (DETERMINISTIC)
│   │   │   ├── coderAgent.ts            # Spec + Assets -> Phaser 3 JS Code (LLM)
│   │   │   └── debugAgent.ts            # Error trace -> Surgical code fix (LLM, conditional)
│   │   ├── prompts/                     # System prompts & few-shot templates
│   │   └── providerRouter.ts            # Resilient provider router with 429/credit auto-fallback
│   ├── assets/
│   │   ├── kenneyCatalog.json           # Indexed bank of curated Kenney sprites
│   │   └── soundPresets.ts              # jsfxr sound configuration library
│   ├── sandbox/
│   │   └── runnerTemplate.ts            # Sandboxed HTML/JS wrapper for iframe
│   ├── export/
│   │   └── zipGenerator.ts              # JSZip bundler for downloadable offline game
│   └── supabase/
│       ├── client.ts                    # Client-side Supabase browser client
│       ├── server.ts                    # Server-side Supabase SSR client
│       └── middleware.ts                # Middleware session verification & RLS routing
├── types/
│   ├── game.ts                          # Game, GameVersion, Prompt types
│   ├── spec.ts                          # Structured Game Spec Zod schema
│   └── admin.ts                         # LLM Provider configuration schema
├── public/
│   └── assets/sprites/                  # Kenney CC0 asset bank hosted static files
├── package.json
└── tailwind.config.ts
```

---

## 4. Multi-Agent Data Flow & Resilient Fallback Routing

### 4.1 Automated Fallback Execution Loop
To counter Claude credit exhaustion and rate-limit spikes without disrupting user sessions, the LLM router implements an automated circuit breaker:

```typescript
// lib/ai/providerRouter.ts
export async function executeLLMWithFallback(
  stage: 'spec_agent' | 'coder_agent' | 'debug_agent', 
  prompt: string, 
  systemPrompt: string,
  schema?: any
) {
  const config = await getAgentLLMConfig(stage); // Retrieves primary and fallback from DB
  
  try {
    // 1. Attempt call with Primary Model (e.g., Claude 3.7 Sonnet)
    return await callModel({
      provider: config.primary_provider,
      model: config.primary_model_name,
      prompt,
      systemPrompt,
      schema,
      temperature: config.temperature,
      maxTokens: config.max_tokens
    });
  } catch (error: any) {
    const isCreditOrQuotaError = 
      error.status === 429 || 
      error.status === 402 || 
      error.message?.toLowerCase().includes('insufficient_quota') ||
      error.message?.toLowerCase().includes('credit_balance') ||
      error.message?.toLowerCase().includes('overloaded') ||
      error.status === 529;

    // 2. If Primary is exhausted and Fallback (e.g., Gemini 2.0 Flash) is configured:
    if (isCreditOrQuotaError && config.fallback_provider && config.fallback_model_name) {
      console.warn(`[LLM Router] ${config.primary_model_name} quota exhausted. Transitioning to fallback: ${config.fallback_model_name}`);
      
      // Update DB to mark primary quota exhausted to short-circuit future calls temporarily
      await markPrimaryQuotaExhausted(stage, true);

      const fallbackResult = await callModel({
        provider: config.fallback_provider,
        model: config.fallback_model_name,
        prompt,
        systemPrompt,
        schema,
        temperature: config.temperature,
        maxTokens: config.max_tokens
      });

      return {
        ...fallbackResult,
        _fallbackTriggered: true,
        _fallbackNotice: `Switched from ${config.primary_model_name} to ${config.fallback_model_name} due to credit limit.`
      };
    }
    
    // If both fail or no fallback configured, rethrow structured error
    throw error;
  }
}
```

### 4.2 Multi-Agent Lifecycle Pipeline

```
1. User Prompt: "Make a retro asteroid shooter where ship shoots green lasers"
   │
   ▼
2. Spec Agent (LLM: Gemini 2.0 Flash / GPT-4o-mini)
   - Outputs: Strict GameSpec JSON
   - Cost: ~$0.001 per call
   │
   ▼
3. Asset Mapper (DETERMINISTIC — Zero LLM Cost)
   - Keyword/entity matching against curated Kenney Catalog
   - Maps game entities to sprite assets + jsfxr audio presets
   - Falls back to Phaser primitive shapes if no match found
   - Cost: $0 (no API call)
   │
   ▼
4. Coder Agent (LLM: Claude 3.5/3.7 Sonnet ──► Fallback: Gemini 2.0 Flash)
   - Receives: GameSpec + AssetManifest
   - Outputs: Complete, standalone Phaser 3 JavaScript
   - Cost: ~$0.02 per call
   │
   ▼
5. Sandboxed Preview Execution
   - Mounted in <iframe sandbox="allow-scripts">
   │
   ▼
6. Debug / Self-Healing Agent (LLM, conditional — only on error)
   - Triggered only if runtime exception caught via window.onerror
   - Max 3 auto-heal cycles to control costs
   - Cost: ~$0.015 per cycle (only if error occurs)
```

**Total Cost Per Game:**
- Happy path (no errors): ~$0.02
- With 1 debug cycle: ~$0.035
- With 3 debug cycles: ~$0.065
- Maximum (3 debug + fallback): ~$0.08

---

## 5. Asset Mapper — Deterministic Zero-Cost Pipeline

The Asset Mapper is **not an LLM agent**. It is a deterministic matching engine that eliminates API costs for asset selection.

### 5.1 How It Works

```typescript
// lib/ai/agents/assetMapper.ts
export function mapAssets(spec: GameSpec): AssetManifest {
  const manifest: AssetManifest = {
    sprites: [],
    audio: []
  };

  // 1. Match entities to Kenney assets via keyword/tags
  for (const entity of spec.entities) {
    const match = findBestKenneyMatch(entity.type, entity.tags);
    
    if (match) {
      manifest.sprites.push({
        key: entity.name,
        url: match.cdnUrl,
        fallback: match.fallbackColor // Hex color for primitive shape fallback
      });
    } else {
      // No match found — use Phaser primitive shape
      manifest.sprites.push({
        key: entity.name,
        primitive: true,
        shape: entity.shape || 'rectangle',
        color: entity.color || 0x6366f1,
        width: entity.width || 32,
        height: entity.height || 32
      });
    }
  }

  // 2. Map audio events to jsfxr presets
  for (const event of spec.audioEvents) {
    const preset = jsfxrPresets[event.type] || jsfxrPresets['default'];
    manifest.audio.push({
      key: event.name,
      params: preset
    });
  }

  return manifest;
}
```

### 5.2 Kenney Catalog Structure

```json
// lib/assets/kenneyCatalog.json
{
  "categories": {
    "space": {
      "tags": ["shooter", "space", "sci-fi"],
      "assets": [
        { "name": "playerShip1_blue", "tags": ["player", "ship", "blue"], "url": "/sprites/space/playerShip1_blue.png" },
        { "name": "enemyBlack1", "tags": ["enemy", "ship", "black"], "url": "/sprites/space/enemyBlack1.png" },
        { "name": "laserBlue01", "tags": ["projectile", "laser", "blue"], "url": "/sprites/space/laserBlue01.png" }
      ]
    },
    "platformer": {
      "tags": ["platformer", "jump", "side-scrolling"],
      "assets": [
        { "name": "player_walk1", "tags": ["player", "character"], "url": "/sprites/platformer/player_walk1.png" },
        { "name": "grass", "tags": ["platform", "ground"], "url": "/sprites/platformer/grass.png" },
        { "name": "coin", "tags": ["collectible", "item"], "url": "/sprites/platformer/coin.png" }
      ]
    }
  }
}
```

### 5.3 Fallback Strategy

When no Kenney asset matches:
1. Use **Phaser primitive shapes** (rectangle, circle, triangle)
2. Apply **entity color** from spec or default indigo (`#6366F1`)
3. Log missing asset for future catalog expansion

This ensures games are always playable even with incomplete asset coverage.

---

## 6. Security, Edge Authentication & Admin RBAC

### 6.1 Edge Route Guard (`middleware.ts`)
Unauthorized requests to `/admin/*` are blocked at the CDN/Edge boundary before reaching server routes:

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request: { headers: request.headers } });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => request.cookies.set(name, value));
          response = NextResponse.next({ request: { headers: request.headers } });
          cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();

  // 1. Unauthenticated redirect
  if (!user && (request.nextUrl.pathname.startsWith('/studio') || request.nextUrl.pathname.startsWith('/dashboard') || request.nextUrl.pathname.startsWith('/admin'))) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // 2. Admin Route Protection (RBAC)
  if (user && request.nextUrl.pathname.startsWith('/admin')) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();

    if (!profile || profile.role !== 'admin') {
      // Forbidden: redirect to creator dashboard
      return NextResponse.redirect(new URL('/dashboard?error=unauthorized_admin', request.url));
    }
  }

  return response;
}

export const config = {
  matcher: ['/admin/:path*', '/studio/:path*', '/dashboard/:path*']
};
```

### 6.2 Sandboxed iFrame Isolation
* The sandbox operates strictly under `sandbox="allow-scripts"`.
* `allow-same-origin` is permanently disabled, forbidding access to authentication tokens, session cookies, and the parent DOM.

### 6.3 GitHub Token Encryption
GitHub Personal Access Tokens are **encrypted at the application layer** using AES-256-GCM before storage in Supabase:

```typescript
// lib/encryption.ts
import { createCipheriv, createDecipheriv, randomBytes, scryptSync } from 'crypto';

const ENCRYPTION_KEY = scryptSync(process.env.GITHUB_TOKEN_SECRET!, 'salt', 32);

export function encryptToken(token: string): string {
  const iv = randomBytes(16);
  const cipher = createCipheriv('aes-256-gcm', ENCRYPTION_KEY, iv);
  const encrypted = Buffer.concat([cipher.update(token, 'utf8'), cipher.final()]);
  const authTag = cipher.getAuthTag();
  return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted.toString('hex')}`;
}

export function decryptToken(encrypted: string): string {
  const [ivHex, authTagHex, encryptedHex] = encrypted.split(':');
  const decipher = createDecipheriv('aes-256-gcm', ENCRYPTION_KEY, Buffer.from(ivHex, 'hex'));
  decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));
  return decipher.update(encryptedHex, 'hex') + decipher.final('utf8');
}
```
