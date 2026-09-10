# Site Map & User Navigation Architecture — GameForge AI

## 1. Visual Hierarchy (Figma Jam / Mindmap Compatible)

```
GameForge AI Platform
├── [Public Domain]
│   ├── Landing Page (/)
│   │   ├── Hero & Value Proposition
│   │   ├── Interactive Showcase / Featured Games
│   │   ├── Feature Matrix (Multi-Agent, Self-Healing, 2D Engine)
│   │   └── Primary CTA ("Start Building Free")
│   ├── Authentication
│   │   ├── Login (/login)
│   │   │   ├── Email/Password Form
│   │   │   └── Google OAuth SSO
│   │   └── Register (/register)
│   │       ├── Account Registration Form
│   │       └── Terms & Quota Overview
│   └── Public Play Experience (/play/[slug])
│       ├── Standalone Sandboxed Game Runner (Full Canvas)
│       ├── Game Metadata (Title, Author, Genre, Play Counter)
│       ├── Responsive Touch / Keyboard Controls
│       ├── Share Bar (Copy Link, QR Code, Social Share)
│       └── "Remix on GameForge AI" CTA
│
├── [Creator Workspace] (Authenticated via Supabase Auth)
│   ├── Creator Dashboard (/dashboard)
│   │   ├── Top Bar (User Profile, Quota Badge, Settings Link)
│   │   ├── "Create New Game" Modal Trigger
│   │   │   └── Fast Prompt Starter Modal
│   │   ├── Project Grid ("My Games")
│   │   │   └── Project Card (Thumbnail, Title, Last Edited, Version Count, Actions)
│   │   └── Community Showcase Feed
│   ├── Account Settings (/settings)
│   │   ├── Profile Settings (Name, Avatar, Password)
│   │   ├── Usage & API Limits (Daily Prompt Counter, Tier Limit)
│   │   └── Integrations (GitHub Personal Access Token / OAuth Link)
│   └── Split-Screen Studio Builder (/studio/[gameId])
│       ├── Studio Header Bar
│       │   ├── Editable Project Title
│       │   ├── Version Badge & Status Indicator (Playable / Building / Healing)
│       │   ├── View Mode Toggle (Game View | Code View | Split View)
│       │   └── Action Buttons (Save, Reset, Publish Modal Trigger)
│       ├── Left Panel: Conversational Director (40% width)
│       │   ├── Pipeline Progress Stepper (Spec -> Assets -> Code -> Live)
│       │   ├── Chat Stream & Message History
│       │   ├── Incremental Suggestion Chips ("Add High Score", "Boost Speed", "Change Controls")
│       │   └── Prompt Input Box & Token Cost Indicator
│       ├── Right Panel: Game Execution & Code Inspection (60% width)
│       │   ├── Sandboxed iframe Runner (Phaser 3 Canvas + jsfxr Audio)
│       │   ├── Monaco Code Editor & Live Diff Drawer
│       │   ├── Game Canvas Controls (Restart, Pause, Mute Audio, Fullscreen)
│       │   └── Autonomous Self-Healing Console Drawer
│       │       ├── Error Intercept Logs
│       │       └── Self-Healing State (Cycle 1-3 Tracker & Patch Feedback)
│       └── Studio Modals & Overlays
│           └── Publish & Export Modal
│               ├── Tab 1: Instant Public Share Link (/play/[slug] + QR Code)
│               ├── Tab 2: Download Standalone ZIP (HTML + JS + Assets)
│               └── Tab 3: Export to GitHub (Direct Repository Commit)
│
└── [Administrative Hub] (Restricted: Role == 'admin')
    └── Dynamic LLM Orchestration Portal (/admin/llm-config)
        ├── Global Status & Latency Monitor
        ├── Pipeline Stage Model Switcher
        │   ├── 1. Spec Engine Agent Model Selector (Gemini / GPT-4o-mini / DeepSeek)
        │   ├── 2. Asset Mapper RAG Model Selector
        │   ├── 3. Coder Agent Model Selector (Claude 3.7 / DeepSeek-V3)
        │   └── 4. Self-Healing Debugger Model Selector
        ├── Encrypted API Key Management (Claude, OpenAI, DeepSeek, Gemini)
        └── Test Generation Sandbox & Ping Latency Benchmark
```

---

## 2. Route Access & Authorization Matrix

| Route Path | View / Feature | Access Level | Data Source / Dependencies |
| :--- | :--- | :--- | :--- |
| `/` | Landing Page & Public Showcase | Public | `games` (where `is_published = true`) |
| `/login` | User Login & OAuth | Public (Guest only) | Supabase Auth |
| `/register` | User Registration | Public (Guest only) | Supabase Auth + `profiles` creation |
| `/play/[slug]` | Standalone Playable Game Runner | Public | `games`, `game_versions` |
| `/dashboard` | User Project Dashboard & Creation Hub | Authenticated (Creator) | `profiles`, `games` (filtered by `user_id`) |
| `/settings` | Profile, Limits, & GitHub Integration | Authenticated (Creator) | `profiles` |
| `/studio/[gameId]` | Split-Screen Studio Builder & Self-Healing Engine | Authenticated (Owner) | `games`, `game_versions`, `prompt_logs` |
| `/admin/llm-config` | Dynamic LLM Selector & Secret Management | Admin Only (`role = 'admin'`) | `llm_configs`, `profiles` |

---

## 3. Core Component Wireframe Hierarchy

### 3.1 Dashboard Layout (`/dashboard`)
```
+-----------------------------------------------------------------------------------------------+
| [≡] GameForge AI                                    [AI Game Generator UI]    [⚙] [Share]   |
+----------+------------------------------------------------------------------------------------+
|          |                                                                                    |
|  [Logo]  |                              HERO SECTION                                        |
|          |                                                                                    |
| + New    |                        [GameForge Icon]                                          |
|  Game    |                                                                                    |
|          |                        Hello [First Name]                                        |
| ─────────|                        Got a game idea today?                                    |
| Overview |                                                                                    |
| Insights |  +------------------------------------------------------------------------------+  |
| Observe  |  | Prompt Input Box:                                                            |  |
| ─────────|  |                                                                              |  |
| PROJECTS |  |   How can I help you?                                                        |  |
| ▼ Neon   |  |                                                                              |  |
│   Platform│  |   [+] [Standard ▼]                                            [↵ Send]    |  |
│   ├ index│  +------------------------------------------------------------------------------+  |
│   ├ canvas│                                                                                   |
│   └ physics|  YOUR LATEST GAMES                                                              |
│  ▶ Asteroid|  +--------------+  +--------------+  +--------------+                           |
│  ▶ Dungeon |  | Neon         |  | Asteroid     |  | Dungeon      |                           |
│  ▶ Bubble  |  | Platformer   |  | Storm        |  | Tiles        |                           |
│ ─────────|  | [Active]       |  | [Offline]    |  | [Draft]      |                           |
│ SYSTEM   |  | canvas physics |  | canvas       |  | grid         |                           |
│ Support  |  | 8 levels       |  | particles    |  | turn-based   |                           |
│ Docs     |  +--------------+  +--------------+  +--------------+                           |
│ ─────────|                                                                                    |
│ [👤] James|  TRY AN EXAMPLE                                                                   |
│  Pro Plan|  +------------------------------------------------------------------------------+  |
│          |  | A side-scrolling platformer collecting glowing orbs...                       |  |
│          |  +------------------------------------------------------------------------------+  |
│          |  | Top-down dungeon crawler with procedural rooms and melee combat              |  |
│          |  +------------------------------------------------------------------------------+  |
│          |  | Endless runner on a spaceship dodging asteroids...                           |  |
│          |  +------------------------------------------------------------------------------+  |
│          |                                                                                    |
+----------+------------------------------------------------------------------------------------+
```

### 3.2 Split-Screen Studio Layout (`/studio/[gameId]`)
```
+-----------------------------------------------------------------------------------------------+
| [≡] GameForge AI  |  [Game Title: Cyberpunk Blaster v2]  [Status: Playable]  [View ▼] [Pub] |
+----------+------------------------------------------------------------------------------------+
|          |                                                                                    |
|  PROJECT |  LEFT PANEL (40%): Prompt & Conversation                                           |
|  FILES   |  +------------------------------------------------------------------------------+  |
|  ────────|  | Pipeline Progress: [✓] Analyzing Idea → [✓] Building Assets → [○] Coding   |  |
|  ▼ Neon  |  +------------------------------------------------------------------------------+  |
|   index  |                                                                                    |
|   canvas |  +------------------------------------------------------------------------------+  |
|   physics|  | [User]: "Make player faster & add laser sound"                               |  |
|   audio  |  |                                                                              |  |
|   └ part │  | [AI]: "Updated speed to 320px/s and added 8-bit laser synthesis."            |  |
|  ▶ Astero|  +------------------------------------------------------------------------------+  |
|          |                                                                                    |
|          |  +------------------------------------------------------------------------------+  |
|          |  | [Type your idea or changes...]                                     [Send]  |  |
|          |  | [Add Score] [Change Colors] [Add Enemies] [Boost Speed]                      |  |
|          |  +------------------------------------------------------------------------------+  |
|          |                                                                                    |
|          |  RIGHT PANEL (60%): Game Preview & Code                                            |
|          |  +------------------------------------------------------------------------------+  |
|          |  | [Game Preview]  [Code View]  [Split View]                                    |  |
|          |  +------------------------------------------------------------------------------+  |
|          |  |                                                                              |  |
|          |  |                    +---------------------+                                   |  |
|          |  |                    |                     |                                   |  |
|          |  |                    |   Phaser 3 Canvas   |                                   |  |
|          |  |                    |   (Playable Game)   |                                   |  |
|          |  |                    |                     |                                   |  |
|          |  |                    +---------------------+                                   |  |
|          |  |                                                                              |  |
|          |  | [▶ Restart] [⏸ Pause] [🔇 Mute] [⛶ Fullscreen]                              |  |
|          |  +------------------------------------------------------------------------------+  |
|          |  | [✓] Game running smoothly — 60 FPS                                         |  |
|          |  +------------------------------------------------------------------------------+  |
|          |                                                                                    |
+----------+------------------------------------------------------------------------------------+
```

### 3.2 Publish & Export Modal (`PublishModal.tsx`)
```
+--------------------------------------------------------------------+
| Modal: Publish & Export Game                                   [X] |
+--------------------------------------------------------------------+
| [ Tab 1: Share Link ] | [ Tab 2: Download ZIP ] | [ Tab 3: GitHub ]|
+--------------------------------------------------------------------+
| Tab 1: Public Play Link                                            |
|   URL: https://gameforge.ai/play/retro-asteroid-blaster-a8f1       |
|   [ Copy Link ]   [ Open Public View ]   [ Download QR Code ]      |
|                                                                    |
| Tab 2: Standalone Offline Package                                  |
|   Includes: index.html, game.js, phaser.min.js, assets/            |
|   [ Download Game (.ZIP) ]                                         |
|                                                                    |
| Tab 3: Sync to GitHub                                              |
|   Target Repo: [ username / my-phaser-game                       ] |
|   Branch:      [ main                                            ] |
|   [ Commit & Push Source Code ]                                    |
+--------------------------------------------------------------------+
```

---

## 4. API Endpoints & Service Routing

```
/api/
├── generate/          [POST]  -> Initial prompt to Spec -> Assets -> Phaser 3 compilation
├── patch/             [POST]  -> Incremental modification prompt to code diff
├── debug/             [POST]  -> Stack trace to surgical fix (max 3 auto-loops)
├── export/
│   ├── zip/           [GET]   -> Generates and streams downloadable .zip archive
│   └── github/        [POST]  -> Pushes full repository to user's GitHub account
└── admin/
    └── llm/           [GET/PUT] -> Retrieves or updates active LLM providers per agent stage
```

---

## 5. User Journey Flowchart (Mermaid)

```mermaid
flowchart TD
    Start([User Visits Platform]) --> Landing[Landing Page /]
    Landing --> AuthCheck{Has Account?}
    
    AuthCheck -- No --> Register[/register]
    AuthCheck -- Yes --> Login[/login]
    Register --> Dashboard[/dashboard]
    Login --> Dashboard
    
    Dashboard --> NewGame[Click 'Create New Game']
    NewGame --> Studio[/studio/:gameId]
    
    subgraph Studio_Loop [Split-Screen Studio Execution]
        Studio --> InputPrompt[Input Natural Language Prompt]
        InputPrompt --> MultiAgent[Spec Agent -> Asset Mapper -> Coder Agent]
        MultiAgent --> RenderSandbox[Mount Code in Sandboxed iframe]
        
        RenderSandbox --> RuntimeCheck{Runtime Error?}
        RuntimeCheck -- Yes (Cycle <= 3) --> DebugAgent[Debug Agent Auto-Heals]
        DebugAgent --> RenderSandbox
        RuntimeCheck -- Yes (Cycle > 3) --> Rollback[Revert to Stable Snapshot]
        
        RuntimeCheck -- No --> InteractivePlay[Game Playable]
        InteractivePlay --> UserIterate{User Tweaks?}
        UserIterate -- Yes --> ChatPatch[Incremental Chat Patch]
        ChatPatch --> RenderSandbox
    end
    
    InteractivePlay --> Publish[Click 'Publish & Share']
    Publish --> ShareOption{Distribution Channel}
    ShareOption --> PublicURL[Public URL /play/:slug]
    ShareOption --> ZipExport[Download Standalone .ZIP]
    ShareOption --> GitHubSync[Push Commit to GitHub Repo]
```
