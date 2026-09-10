# Engineering Conventions, Coding Standards & Limitations — GameForge AI

## 1. Code Style & Conventions

### 1.1 TypeScript & Next.js
* **Strict TypeScript:** `noImplicitAny: true`, `strict: true`. Never use `any`; use typed schemas, `unknown` with type guards, or Zod inference.
* **Component Architecture:** Server Components (`RSC`) by default. Mark Client Components explicitly with `'use client';` only when utilizing state, effects, or browser APIs.
* **Route Protection:** All administrative endpoints and views (`/admin/*`, `/api/admin/*`) MUST be guarded at the Edge via `middleware.ts` verifying `profiles.role === 'admin'`. Never rely solely on client-side route redirects.
* **Naming Conventions:**
  * Components: PascalCase (e.g., `SandboxCanvas.tsx`, `PipelineStepper.tsx`).
  * Hooks: camelCase starting with `use` (e.g., `useSandboxBridge.ts`).
  * Utilities & Actions: camelCase (e.g., `generateGameSpec.ts`, `patchCode.ts`).
  * Database tables & columns: snake_case (e.g., `game_versions`, `source_code`).

---

## 2. Error Handling & Provider Fallback Protocol

### 2.1 Claude Sonnet Credit & Rate-Limit Exhaustion
When Claude credits run out (HTTP 429, 402, or `insufficient_quota`), the system must execute graceful degradation:
1. **Never Show Fatal Crash Screen:** The user must not receive an unhandled error or white screen when an external API quota runs out.
2. **Transparent Automatic Transition:** The `providerRouter.ts` immediately catches the quota exception, reroutes the payload to the configured secondary model (e.g., Google Gemini 2.0 Flash), and sets `_fallbackTriggered: true`.
3. **UI Notice Standard:** The Split-Screen Studio must display a subtle amber toast notification:
   > *"Notice: Primary model credit limit reached. Smoothly transitioned to Gemini 2.0 Flash to finish compiling your game without interruption."*
4. **Permanent Failures:** If both the primary and fallback models fail (e.g., total network outage or both quotas exhausted), return a structured HTTP 429 error with an estimated `retryAfter` timestamp.

### 2.2 User-Facing Quality Selector
The Dashboard and Studio show a simplified "Quality" selector to users:
- **Fast**: Prioritizes speed over quality (maps to lighter/faster models)
- **Balanced** (default): Standard quality and speed trade-off
- **Best**: Prioritizes quality (maps to most capable models)

The actual LLM provider and model selection is handled internally by the admin-configured `providerRouter.ts`. Users never see model names (GPT-4, Claude, etc.) in the UI. The Quality selector is purely a user preference that influences internal routing weights.

---

## 3. Phaser 3 Game Code Generation Guidelines (AI Prompts Standard)

When LLM agents generate Phaser 3 game code, they must strictly follow these structural rules:

1. **Monolithic Self-Contained Script:** The output must be valid, executable vanilla JavaScript that mounts immediately to a `div#game-container`.
2. **Arcade Physics Only:** Do not load Matter.js or external physics engines to preserve memory and sandbox performance.
3. **Phaser Lifecycle Standard:** Must structure code using standard Phaser scenes:
   ```javascript
   const config = {
     type: Phaser.AUTO,
     parent: 'game-container',
     width: 800,
     height: 600,
     physics: { default: 'arcade', arcade: { gravity: { y: 0 }, debug: false } },
     scene: { preload: preload, create: create, update: update }
   };
   const game = new Phaser.Game(config);
   ```
4. **Asset Preloading Safety:**
   * Images MUST use the verified Kenney Asset CDN URLs provided in the Asset Manifest.
   * Do NOT invent external image URLs. If an asset is missing, render a Phaser primitive shape:
     ```javascript
     // Fallback if sprite unavailable
     const rect = this.add.rectangle(x, y, 32, 32, 0x6366f1);
     this.physics.add.existing(rect);
     ```
5. **Procedural Audio (jsfxr):**
   * Audio sound effects must be triggered via the global `jsfxr()` audio synthesizer function injected into the sandbox runner.
   * No external `.mp3` or `.wav` network requests.

---

## 4. AI Agent Limits & Guardrails

To prevent hallucination, infinite loops, and catastrophic cost spikes:

1. **Self-Healing Loop Cap:** Maximum of **3 autonomous debug retries**. If the game still crashes after 3 cycles:
   * Stop automated execution.
   * Revert sandbox to previous stable version snapshot (`game_versions.source_code`).
   * Display human-readable error notification to the creator with an option to manually describe the fix.
2. **Token Guardrails:**
   * Maximum output tokens per Coder Agent response: **4,096 tokens**.
   * Strip all explanatory markdown prose when generating game code; instruct LLM to output pure code wrapped in standard delimiters.
3. **Prompt Injection Mitigation:**
   * User prompt input is sanitized and wrapped inside rigid system delimiters (`<user_prompt>...</user_prompt>`).
   * The system instructions strictly enforce game creation context only. Prompts attempting system prompt leakage or arbitrary code execution are rejected.

---

## 5. Contributor & Team Workflow Rules (3-Engineer Team)

* **Branching Strategy:**
  * `main` is production-ready and protected (requires 1 review before merge).
  * Feature branches follow convention: `feat/dev1-llm-router`, `feat/dev2-studio-ui`, `feat/dev3-kenney-assets`.
* **Database Migrations:** Never modify database tables directly via Supabase dashboard in staging/production. All schema changes must be committed as versioned SQL migrations in `supabase/migrations/`.
* **Sync Checkpoints:** Strict daily sync at **16:00 WIB** to verify cross-engineer integration points as defined in the Sprint Schedule.
