# UI/UX & Technical Design Document — GameForge AI

## 1. Design System & Style Guide

GameForge AI follows a **Lovable-inspired** design philosophy: a unified, approachable platform that empowers non-technical users to create games through natural language, while still surfacing technical progress in a friendly, non-intimidating way. The aesthetic is clean, modern, and warm — dark mode by default with soft gradients, rounded surfaces, and clear visual hierarchy.

### Design Principles
1. **Approachable First**: Every screen should feel like a creative tool, not a code editor
2. **Progressive Disclosure**: Technical details (file tree, code view) are available but not front-and-center
3. **Consistent Language**: Use game-making terminology, not programming jargon
4. **Celebrate Progress**: Generation stages, file creation, and successful builds are visually celebrated

### Color Palette (Tailwind Tokens)
* **Background Canvas:** `#0B0F1A` (`bg-slate-950`) — Deep navy void with subtle indigo undertone.
* **Background Gradient:** `from-slate-950 via-slate-900 to-indigo-950/30` — Soft radial gradient for main content areas.
* **Surface / Cards:** `#141827` (`bg-slate-900`) — Elevated dark surface with subtle border.
* **Surface Hover:** `#1A1F2E` (`bg-slate-800/50`) — Gentle hover state.
* **Border Lines:** `#1E293B` (`border-slate-800`) — Clean structural framing.
* **Primary Accent:** `#6366F1` (`indigo-500`) — AI actions, generation, primary CTA.
* **Accent Hover:** `#4F46E5` (`indigo-600`) — Interactive button hover.
* **Success / Healing:** `#10B981` (`emerald-500`) — Self-healing active, game compiled successfully.
* **Warning / Alert:** `#F59E0B` (`amber-500`) — Rate limit warning, self-healing in progress.
* **Destructive:** `#EF4444` (`red-500`) — Runtime crash detected, quota exceeded.
* **Text Hierarchy:**
  * Title: `#F8FAFC` (`text-slate-50`)
  * Body: `#94A3B8` (`text-slate-400`)
  * Muted: `#64748B` (`text-slate-500`)
  * Subtle: `#475569` (`text-slate-600`)

### Typography
* **Primary Sans:** Inter (`sans-serif`) for general UI, buttons, inputs, modals.
* **Monospace:** JetBrains Mono / Fira Code (`monospace`) for prompts, console logs, and code previews.
* **Scale**: Use generous font sizes for headings to create breathing room.

### Spacing & Shape
* **Border Radius**: Cards use `rounded-2xl` (16px), buttons use `rounded-xl` (12px), small tags use `rounded-lg` (8px)
* **Shadows**: Soft, diffuse shadows — `shadow-lg shadow-black/20`
* **Card Padding**: Generous internal padding — `p-6` to `p-8`
* **Transitions**: Smooth 200ms transitions on all interactive elements

---

## 2. Shared Layout Components

### 2.1 App Shell — Collapsible Sidebar + Main Content
All authenticated pages share a consistent shell:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  [≡]  GameForge AI                              [AI Game Generator UI]    [⚙] [Share]     │
├──────────┬──────────────────────────────────────────────────────────────────────────────────┤
│          │                                                                                  │
│  [Logo]  │                         MAIN CONTENT AREA                                      │
│          │                  (Gradient background, floating cards)                         │
│ + New    │                                                                                  │
│  Game    │                                                                                  │
│          │                                                                                  │
│ ─────────│                                                                                  │
│ Overview │                                                                                  │
│ Insights │                                                                                  │
│ Observe  │                                                                                  │
│ ─────────│                                                                                  │
│ PROJECTS │                                                                                  │
│ ▼ Neon   │                                                                                  │
│   Platform│                                                                                 │
│   ├ index│                                                                                  │
│   ├ canvas│                                                                                 │
│   └ physics│                                                                                │
│ ▶ Asteroid│                                                                                 │
│ ▶ Dungeon │                                                                                  │
│ ▶ Bubble  │                                                                                  │
│ ─────────│                                                                                  │
│ SYSTEM   │                                                                                  │
│ Support  │                                                                                  │
│ Docs     │                                                                                  │
│ ─────────│                                                                                  │
│ [👤] James│                                                                                 │
│  Pro Plan│                                                                                  │
│          │                                                                                  │
└──────────┴──────────────────────────────────────────────────────────────────────────────────┘
```

#### Sidebar Components:
1. **Logo & Brand**: GameForge AI with icon, collapsible to icon-only
2. **Primary CTA**: "+ New Game" button — prominent indigo button, always visible
3. **Navigation Links**: Overview, Insights, Observe — with icons and optional badge counts
4. **Projects Section**: Collapsible tree of user's games
   - Each game expandable to show generated files (`index.js`, `canvas.js`, `physics.js`, etc.)
   - Clicking a game navigates to `/studio/[gameId]`
   - Clicking a file opens it in Code View within the studio
5. **System Links**: Support, Docs — bottom section
6. **User Profile**: Avatar, name, plan badge — click opens account menu

#### Sidebar States:
- **Expanded** (default on desktop): 260px width, full text labels
- **Collapsed**: 72px width, icons only, tooltips on hover
- **Mobile**: Hidden by default, slides in as overlay

---

## 3. Core Screen Layouts

### 3.1 Dashboard (`/dashboard`)
The welcoming home screen — user's first view after login.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  [Sidebar]  │                                                                               │
│             │   [Logo Icon]                                                                 │
│             │                                                                               │
│             │   Hello James                                                                 │
│             │   Got a game idea today?                                                      │
│             │                                                                               │
│             │   ┌─────────────────────────────────────────────────────────────────────┐     │
│             │   │  How can I help you?                                                │     │
│             │   │                                                                     │     │
│             │   │  [+] [Standard ▼]                                          [↵]    │     │
│             │   └─────────────────────────────────────────────────────────────────────┘     │
│             │                                                                               │
│             │   YOUR LATEST GAMES                                                           │
│             │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│             │   │ Neon         │  │ Asteroid     │  │ Dungeon      │                       │
│             │   │ Platformer   │  │ Storm        │  │ Tiles        │                       │
│             │   │ [Active]     │  │ [Offline]    │  │ [Draft]      │                       │
│             │   │ canvas       │  │ canvas       │  │ grid         │                       │
│             │   │ physics      │  │ particles    │  │ turn-based   │                       │
│             │   │ 8 levels     │  │              │  │              │                       │
│             │   └──────────────┘  └──────────────┘  └──────────────┘                       │
│             │                                                                               │
│             │   TRY AN EXAMPLE                                                              │
│             │   ┌─────────────────────────────────────────────────────────────────────┐     │
│             │   │ A side-scrolling platformer collecting glowing orbs...              │     │
│             │   ├─────────────────────────────────────────────────────────────────────┤     │
│             │   │ Top-down dungeon crawler with procedural rooms and melee combat     │     │
│             │   ├─────────────────────────────────────────────────────────────────────┤     │
│             │   │ Endless runner on a spaceship dodging asteroids...                  │     │
│             │   └─────────────────────────────────────────────────────────────────────┘     │
│             │                                                                               │
└─────────────┴───────────────────────────────────────────────────────────────────────────────┘
```

#### Dashboard Components:

**Hero Section:**
- Centered logo icon (GameForge AI mark)
- Large greeting: "Hello [First Name]"
- Subtitle: "Got a game idea today?"

**Prompt Input Box:**
- Large, rounded-2xl white/light card with shadow
- Placeholder: "How can I help you?"
- Bottom row:
  - `[+]` button for attachments (future: upload reference images)
  - `[Standard ▼]` quality selector (simplified: Fast / Balanced / Best — maps to internal LLM config)
  - `[↵]` send button (indigo, circular)
- **Note**: Model selector is user-facing as "Quality" only. Actual LLM routing is handled silently by the admin-configured provider router.

**Your Latest Games:**
- Horizontal scrollable row of game cards (3 visible on desktop)
- Each card:
  - Game title (bold)
  - Status badge: `Active` (green), `Draft` (amber), `Offline` (slate)
  - Genre tag: `Platformer`, `Shooter`, `RPG`
  - File tags: `canvas`, `physics`, `particles`, etc. (shows 2-3 key files)
  - Click card → navigate to `/studio/[gameId]`

**Try an Example:**
- Dynamically pulled from most-played or recently-created public games
- Each example is a clickable prompt card
- Clicking auto-fills the prompt input and starts generation
- Rotates daily/weekly from community content

---

### 3.2 The Split-Screen Studio (`/studio/[gameId]`)
The core creation environment — redesigned to match the platform aesthetic while preserving all technical capabilities.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  [Sidebar]  │  [Game Title: Cyberpunk Blaster v2]  [Status: Playable]  [View ▼] [Publish] │
├──────────┬──┴───────────────────────────────────────────────────────────────────────────────┤
│          │                                                                                  │
│  PROJECT │  LEFT PANEL (40%): Prompt & Conversation                                       │
│  FILES   │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│  ────────│  │ Pipeline Progress: [✓] Analyzing Idea → [✓] Building Assets → [○] Coding │  │
│  ▼ Neon  │  └────────────────────────────────────────────────────────────────────────────┘  │
│   index  │                                                                                  │
│   canvas │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│   physics│  │ [User]: "Make player faster & add laser sound"                             │  │
│   audio  │  │                                                                              │  │
│   └ particles│ [AI]: "Updated speed to 320px/s and added 8-bit laser synthesis."       │  │
│  ▶ Asteroid│  │                                                                            │  │
│          │  └────────────────────────────────────────────────────────────────────────────┘  │
│          │                                                                                  │
│          │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│          │  │ [Type your idea or changes...]                                    [Send] │  │
│          │  │ [Add Score] [Change Colors] [Add Enemies] [Boost Speed]                    │  │
│          │  └────────────────────────────────────────────────────────────────────────────┘  │
│          │                                                                                  │
│          │  RIGHT PANEL (60%): Game Preview & Code                                        │
│          │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│          │  │  [Game Preview]  [Code View]  [Split View]                                 │  │
│          │  ├────────────────────────────────────────────────────────────────────────────┤  │
│          │  │                                                                            │  │
│          │  │                    ┌─────────────────────┐                                 │  │
│          │  │                    │                     │                                 │  │
│          │  │                    │   Phaser 3 Canvas   │                                 │  │
│          │  │                    │   (Playable Game)   │                                 │  │
│          │  │                    │                     │                                 │  │
│          │  │                    └─────────────────────┘                                 │  │
│          │  │                                                                            │  │
│          │  │  [▶ Restart] [⏸ Pause] [🔇 Mute] [⛶ Fullscreen]                           │  │
│          │  ├────────────────────────────────────────────────────────────────────────────┤  │
│          │  │  [✓] Game running smoothly — 60 FPS                                        │  │
│          │  └────────────────────────────────────────────────────────────────────────────┘  │
│          │                                                                                  │
└──────────┴──────────────────────────────────────────────────────────────────────────────────┘
```

#### Studio Components:

**Header Bar:**
- Editable game title (click to rename)
- Status indicator: `Building...` (amber pulse), `Playable` (green), `Healing` (amber animate)
- View toggle: `Game Preview` | `Code View` | `Split View`
- `Publish` button (indigo)

**Left Panel — Prompt & Conversation:**
1. **Pipeline Progress**: Friendly, non-technical stage indicator
   - "Analyzing Idea" → "Building Assets" → "Coding Game" → "Ready to Play"
   - Uses animated dots/spinner during active stage
   - Green checkmarks for completed stages
2. **Chat Stream**: Conversation between user and AI
   - User messages: right-aligned, indigo tint
   - AI messages: left-aligned, with small avatar/icon
   - System messages (e.g., "Game saved automatically"): centered, muted
3. **Prompt Input**: Same rounded-2xl style as dashboard
   - Quick-action chips below: "Add Score", "Change Colors", "Add Enemies", "Boost Speed"
   - Chips dynamically suggested based on current game state

**Right Panel — Game Preview & Code:**
1. **View Modes**:
   - `Game Preview`: Full sandboxed iframe (Phaser 3 canvas)
   - `Code View`: Monaco editor with syntax-highlighted JS, read-only by default
   - `Split View`: Game on top, code below (or side-by-side on large screens)
2. **Game Canvas**: Sandboxed iframe, centered with subtle shadow
3. **Canvas Controls**: Restart, Pause/Resume, Mute, Fullscreen
4. **Status Bar**: Collapsible bottom bar
   - Healthy: green dot, "Game running smoothly — 60 FPS"
   - Error: red dot, auto-expands to show error + healing progress

#### Sidebar in Studio Context:
- Shows **current game's file tree** expanded by default
- Files are clickable — opens Code View scrolled to that file
- Other games collapsed but accessible
- "+ New Game" still available for quick creation

---

### 3.3 Admin LLM Configuration Portal (`/admin/llm-config`)
Restricted view for platform administrators. Uses the same shell but with admin-specific navigation.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  [Sidebar]  │  Admin: LLM Orchestration Hub                                    [Save All] │
├──────────┬──┴───────────────────────────────────────────────────────────────────────────────┤
│          │                                                                                  │
│  ADMIN   │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│  ────────│  │ System Status: All systems operational  [●] Healthy                          │  │
│  Overview│  └────────────────────────────────────────────────────────────────────────────┘  │
│  LLM     │                                                                                  │
│  Config  │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│  Users   │  │ Agent Pipeline Configuration                                                 │  │
│  Billing │  ├────────────────────────────────────────────────────────────────────────────┤  │
│          │  │                                                                              │  │
│          │  │ Stage                  Primary Model              Fallback Model             │  │
│          │  │ ─────────────────────  ─────────────────────────  ─────────────────────────  │  │
│          │  │ 1. Spec Engine         [ Google: Gemini 2.0 Flash ▼ ] [ OpenAI: GPT-4o-mini]│  │
│          │  │ 2. Asset Mapper        [ Google: Gemini 2.0 Flash ▼ ] [ Internal Keyword   ]│  │
│          │  │ 3. Coder Agent         [ DeepSeek: DeepSeek-V3    ▼ ] [ Anthropic: Claude  ]│  │
│          │  │ 4. Debug / Self-Heal   [ Anthropic: Claude 3.7   ▼ ] [ DeepSeek: DeepSeek ]│  │
│          │  │                                                                              │  │
│          │  └────────────────────────────────────────────────────────────────────────────┘  │
│          │                                                                                  │
│          │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│          │  │ Provider API Keys                                                            │  │
│          │  ├────────────────────────────────────────────────────────────────────────────┤  │
│          │  │ Anthropic Claude:  [ •••••••••••••••••••••••••••••••••••••••••••••••• ] │  │
│          │  │ DeepSeek:          [ •••••••••••••••••••••••••••••••••••••••••••••••• ] │  │
│          │  │ OpenAI:            [ •••••••••••••••••••••••••••••••••••••••••••••••• ] │  │
│          │  │ Google Gemini:     [ •••••••••••••••••••••••••••••••••••••••••••••••• ] │  │
│          │  │                                                                              │  │
│          │  │ [ Test All Connections ]  [ Save Configuration ]                             │  │
│          │  └────────────────────────────────────────────────────────────────────────────┘  │
│          │                                                                                  │
│          │  ┌────────────────────────────────────────────────────────────────────────────┐  │
│          │  │ Latency Benchmarks                                                           │  │
│          │  │ ┌─────────────┬─────────────┬─────────────┬─────────────┐                   │  │
│          │  │ │ Provider    │ Avg Latency │ Success Rate│ Last Ping   │                   │  │
│          │  │ ├─────────────┼─────────────┼─────────────┼─────────────┤                   │  │
│          │  │ │ Claude 3.7  │ 2.3s        │ 99.2%       │ 2 min ago   │                   │  │
│          │  │ │ Gemini Flash│ 1.1s        │ 99.8%       │ 2 min ago   │                   │  │
│          │  │ │ DeepSeek-V3 │ 3.1s        │ 98.5%       │ 2 min ago   │                   │  │
│          │  │ └─────────────┴─────────────┴─────────────┴─────────────┘                   │  │
│          │  └────────────────────────────────────────────────────────────────────────────┘  │
│          │                                                                                  │
└──────────┴──────────────────────────────────────────────────────────────────────────────────┘
```

#### Admin Portal Components:
- Same sidebar shell, but navigation shows admin sections
- Cards use the same `rounded-2xl`, shadow, and surface colors
- Tables use subtle row dividers, not heavy borders
- Status indicators use color-coded dots with pulse animation for active checks

---

### 3.4 Publish & Share Modal
Triggered via the **"Publish"** header button in the Studio. Uses the card-based aesthetic.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  Share Your Game                                                                    [Close] │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  [ Share Link ]  [ Download ZIP ]  [ GitHub ]                                               │
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                                                                                     │    │
│  │  Your game is live! 🎉                                                              │    │
│  │                                                                                     │    │
│  │  https://gameforge.ai/play/retro-asteroid-blaster-a8f1                              │    │
│  │                                                                                     │    │
│  │  [ Copy Link ]  [ Open in New Tab ]  [ Download QR Code ]                           │    │
│  │                                                                                     │    │
│  │  ┌─────────────────────────────┐                                                    │    │
│  │  │                             │                                                    │    │
│  │  │      [QR Code Preview]      │                                                    │    │
│  │  │                             │                                                    │    │
│  │  └─────────────────────────────┘                                                    │    │
│  │                                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Publish Modal Tabs:
1. **Share Link**: Public URL, copy button, QR code preview
2. **Download ZIP**: Offline package with all assets — one-click download
3. **GitHub**: Connect PAT, choose repo name, push source code

---

## 4. Component Specifications

### 4.1 Game Card Component
Used in Dashboard "Your Latest Games" section.

```
┌─────────────────────────────┐
│                             │
│  [Game Thumbnail / Icon]    │
│                             │
│  Game Title                 │
│  [Status] [Genre]           │
│  file1  file2  file3        │
│                             │
└─────────────────────────────┘
```

- **Size**: ~280px wide, auto height
- **Border**: `1px solid border-slate-800`, `rounded-2xl`
- **Background**: `bg-slate-900`, hover: `bg-slate-800/50`
- **Thumbnail**: Game screenshot or generated placeholder icon
- **Status Badge**: 
  - `Active` — `bg-emerald-500/10 text-emerald-400 border-emerald-500/20`
  - `Draft` — `bg-amber-500/10 text-amber-400 border-amber-500/20`
  - `Offline` — `bg-slate-500/10 text-slate-400 border-slate-500/20`
- **File Tags**: Small pills showing key generated files

### 4.2 Prompt Input Component
Shared between Dashboard and Studio.

- **Container**: `bg-white dark:bg-slate-800`, `rounded-2xl`, `shadow-lg`
- **Text Area**: Large, comfortable padding, placeholder in muted color
- **Bottom Row**: Flexbox with attachment button, quality selector, send button
- **Quality Selector**: Simple dropdown — "Fast" / "Balanced" / "Best"
  - Maps internally to LLM config but user sees friendly names only
- **Send Button**: Circular indigo button with arrow icon

### 4.3 Pipeline Progress Component
Studio-only, shows generation status.

- **Style**: Horizontal stepper with connecting line
- **Steps**: 
  1. "Analyzing Idea" — sparkle icon
  2. "Building Assets" — image icon
  3. "Coding Game" — code icon
  4. "Ready to Play" — play icon
- **States**: Pending (muted), Active (indigo with pulse), Complete (green checkmark)
- **Animation**: Smooth transitions between steps, subtle pulse on active

### 4.4 Status Bar Component
Collapsible bottom bar in Studio.

- **Collapsed**: Single line with status dot + brief message
- **Expanded** (on error): Shows error details, healing progress, action buttons
- **Healthy**: Green dot, "Game running smoothly — 60 FPS"
- **Healing**: Amber pulse, "Fixing an issue... (Attempt 1 of 3)"
- **Error**: Red dot, "Unable to fix automatically. Please describe what you see."

---

## 5. Responsive Behavior

### Desktop (>= 1280px)
- Full sidebar expanded by default
- Dashboard: 3 game cards visible
- Studio: 40/60 split between panels

### Tablet (768px - 1279px)
- Sidebar collapsed to icon-only
- Dashboard: 2 game cards visible
- Studio: 50/50 split or stacked panels

### Mobile (< 768px)
- Sidebar hidden, hamburger menu
- Dashboard: 1 game card visible, vertical scroll
- Studio: Stacked panels (prompt on top, preview below)

---

## 6. Sandboxed Communication Contract

Communication between the parent Next.js application and the child iframe uses the HTML5 `window.postMessage` API with strict origin checking:

```typescript
// Message from Studio to Sandbox
type StudioToSandboxMessage = 
  | { type: 'LOAD_GAME'; payload: { code: string; assets: Record<string, string> } }
  | { type: 'RESTART_GAME' }
  | { type: 'PAUSE_GAME' }
  | { type: 'RESUME_GAME' }
  | { type: 'MUTE_AUDIO'; payload: { muted: boolean } };

// Message from Sandbox to Studio
type SandboxToStudioMessage =
  | { type: 'GAME_MOUNTED' }
  | { type: 'GAME_STARTED' }
  | { type: 'RUNTIME_ERROR'; payload: { message: string; stack?: string; lineno?: number } }
  | { type: 'SCORE_UPDATE'; payload: { score: number } };
```
