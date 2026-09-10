# Product Requirements Document (PRD) — GameForge AI

## 1. Executive Summary & Vision
**GameForge AI** is a no-code web platform that transforms natural language prompts into interactive, fully playable 2D web games in real-time. By leveraging a multi-agent AI orchestration pipeline (Spec Agent, Asset Mapper, Coder Agent, Debug/Self-Healing Agent) backed by Phaser 3 and sandboxed browser runtimes, GameForge AI removes the programming barrier for creators, educators, game designers, and hobbyists.

---

## 2. Target Audience & Personas
* **Non-Technical Creators & Hobbyists:** Users with creative game ideas but zero JavaScript/game engine experience.
* **Game Designers & Prototypers:** Rapidly test game mechanics, physics, and gameplay loops in minutes before committing production resources.
* **Educators & Students:** Interactive learning tool for teaching game mechanics, storytelling, and procedural design.
* **Hackathon & Game Jam Participants:** Fast scaffolding of playable prototypes within strict time constraints.

---

## 3. Product Goals & Core Value Propositions
1. **Zero-Code Playable in < 30 Seconds:** Single natural language prompt converts into a running 2D Phaser 3 game.
2. **Conversational Iteration (Hot-Patching):** Chat dialogue to tweak physics, difficulty, speed, spawn rates, or colors without regenerating from scratch.
3. **Autonomous Self-Healing Runtime:** Catches JavaScript runtime/physics errors inside the sandbox, auto-submits trace to LLM, and hot-fixes bugs without user intervention (max 3 cycles).
4. **Zero-Cost Asset Pipeline:** Curated Kenney CC0 asset bank and procedural jsfxr 8-bit audio generation to avoid costly image/audio generation APIs.
5. **Frictionless Distribution:** Instant public playable URL (`/play/[slug]`), HTML/ZIP standalone export, and GitHub Repository Sync.
6. **Provider Agnostic (Admin LLM Hub):** Dynamic provider switcher (Claude 3.5/3.7, DeepSeek V3/R1, OpenAI GPT-4o, Google Gemini 2.0 Flash) managed via an internal admin portal.

---

## 4. Feature Scope (MVP vs. Post-MVP)

| Feature Area | MVP (8-Day Sprint) | Post-MVP Roadmap |
| :--- | :--- | :--- |
| **Authentication** | Supabase Auth (Email/Password & Google OAuth) required from Day 1. | Team collaboration, shared workspaces, role-based access. |
| **Generation Engine** | Multi-stage pipeline: Spec Agent $	o$ Asset Mapper $	o$ Coder Agent. | Multi-scene games (Level 1, Level 2, Boss stage), complex inventory systems. |
| **Engine Runtime** | Phaser 3 (Arcade Physics), single-scene sandboxed `iframe`. | Phaser Matter.js (complex physics), 3D support (Three.js/Babylon.js). |
| **Assets & Audio** | Kenney 2D Sprites (Platformer, Top-down, Shooter) + jsfxr procedural audio parameters. Asset Mapper is **deterministic** (zero LLM cost) via keyword matching. | AI Sprite generation (PixelLab / Stable Diffusion), custom audio stem generation. |
| **Self-Healing** | `window.onerror` + `console.error` postMessage bridge $	o$ LLM Debug Agent (capped at 3 retries). | Visual regression testing, visual canvas inspection via multimodal LLM. |
| **Admin Portal** | Dynamic LLM selection per agent task (Spec, Code, Debug) with API key overrides stored in DB. | Detailed token analytics per user, billing tiers, automated latency routing. |
| **Export & Sharing** | Unique public shareable URL (`/play/[slug]`), standalone ZIP bundle, and GitHub Repo Sync via Personal Access Token/OAuth. | Direct itch.io export, Steam package builder, mobile PWA packaging. |

---

## 5. User Journey & Core Workflows

```
[Landing Page / CTA] 
       │
       ▼
[User Auth (Login / Sign Up)]
       │
       ▼
[Dashboard] ──> Click "Create New Game"
       │
       ▼
[Studio Builder (Split-Screen)]
  ├─ Left Panel: Natural Language Prompt Input ("Make a cyberpunk space shooter...")
  ├─ Multi-Stage Progress: [Analyzing Spec] ➔ [Selecting Assets] ➔ [Synthesizing Phaser 3]
  └─ Right Panel: Sandboxed Canvas initializes and boots Phaser 3 game
       │
       ├─► [User Iterates via Chat]: "Increase enemy speed by 20% and make laser sound higher pitched"
       │         └─► LLM Incremental Patch applied to runtime in < 8s
       │
       ├─► [Runtime Crash Occurs]: 
       │         └─► Sandbox catches error ➔ Debug Agent auto-heals ➔ Reboots game (max 3 loops)
       │
       ▼
[Publish & Share Modal]
  ├─ Generate Public Play URL (/play/[slug])
  ├─ Download Offline HTML/ZIP Bundle
  └─ Push to User's GitHub Repository
```

---

## 6. Technical Requirements & Non-Functional Requirements
* **Performance:** Initial game generation < 25 seconds; incremental chat patches < 8 seconds.
* **Security & Isolation:** The game preview MUST run inside an `iframe` with `sandbox="allow-scripts"` (NO `allow-same-origin`) to prevent access to authentication cookies, local storage, or platform DOM.
* **Reliability:** Self-healing cycle strictly capped at 3 loops to avoid infinite token exhaustion. Fallback to previous stable snapshot if unrecoverable.
* **Responsiveness:** Studio interface responsive on desktop (>= 1280px). Public playable game URL responsive across mobile and desktop browsers with virtual touch controls support.
* **Cost Guardrails:** Per-user daily prompt quota (10 generations/day for free tier, 30 for Creator, 100 for Studio) managed via Redis/Upstash rate limiting. Deterministic Asset Mapper eliminates asset selection API costs. Target cost per game: ~$0.02 (happy path).

---

## 7. Success Metrics & Key Performance Indicators (KPIs)
* **First-Prompt Success Rate:** $\ge 90\%$ of initial generations produce a playable, error-free game.
* **Self-Healing Recovery Rate:** $\ge 80\%$ of runtime syntax or reference errors resolved autonomously by Debug Agent on iteration 1.
* **Time to First Playable Game:** Under 30 seconds from user prompt submission.
* **Sharing Conversion:** $\ge 35\%$ of generated games shared publicly or exported.
