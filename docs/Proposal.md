# GameForge AI — Business Model Proposal

## 1. Executive Summary

GameForge AI is a **freemium no-code platform** that transforms natural language prompts into playable 2D web games. Revenue is generated through tiered subscriptions based on AI generation usage, with a free tier for discovery and paid tiers for serious creators.

---

## 2. Revenue Model

### 2.1 Tier Structure

| Tier | Price | Daily Generations | Features |
|------|-------|-------------------|----------|
| **Free** | $0 | 5 generations/day | Basic games, watermarked share links, community support |
| **Creator** | $9.99/mo | 30 generations/day | No watermark, ZIP export, GitHub sync, priority support |
| **Studio** | $29.99/mo | 100 generations/day | Custom domains, team collaboration, advanced analytics |
| **Enterprise** | Custom | Unlimited | SLA, dedicated support, custom LLM integration, white-label |

### 2.2 Usage-Based Overage
- Additional generations beyond daily limit: **$0.10 per generation**
- Billed at end of cycle or prepaid top-up

### 2.3 Cost Structure (Per Generation)

| Agent Stage | Primary Model | Fallback Model | Avg Cost/Call | Calls/Game |
|-------------|---------------|----------------|---------------|------------|
| Spec Agent | Gemini 2.0 Flash | GPT-4o-mini | $0.001 | 1 |
| Asset Mapper | **Deterministic** | — | **$0** | 1 |
| Coder Agent | Claude 3.5 Sonnet | Gemini 2.0 Flash | $0.02 | 1 |
| Debug Agent (if needed) | Claude 3.5 Sonnet | Gemini 2.0 Flash | $0.015 | 0-3 |
| **Total per game** | | | **~$0.02 - $0.07** | |

**Target margin**: 70%+ at Creator tier ($9.99 covers ~140 generations at cost)

---

## 3. Token Consumption & Quality Preference

The user-facing **Quality selector** directly impacts token usage and cost:

| Quality | Model Tier | Avg Tokens/Game | Cost Multiplier | Use Case |
|---------|------------|-----------------|-----------------|----------|
| **Fast** | Gemini 2.0 Flash / GPT-4o-mini | ~2K tokens | 0.5x | Quick prototypes, testing ideas |
| **Balanced** | Claude 3.5 Sonnet / DeepSeek-V3 | ~4K tokens | 1.0x | Standard game creation |
| **Best** | Claude 3.7 Sonnet / GPT-4o | ~8K tokens | 2.0x | Polished, complex games |

**User preference stored in `profiles.quality_preference`** — can be changed per-prompt or set as default.

---

## 4. Free Tier Strategy

### 4.1 Purpose
- User acquisition and viral growth
- Showcase capability without commitment
- Convert to paid via feature gating

### 4.2 Limitations
- Watermarked share links (`Made with GameForge AI`)
- No ZIP/GitHub export
- 5 generations/day (enough for 1-2 game experiments)
- Games auto-deleted after 30 days of inactivity

### 4.3 Viral Loop
- Free users can share games publicly
- Watermark drives brand awareness
- "Upgrade to remove watermark" CTA on shared games

---

## 5. Payment Integration

### 5.1 Stack
- **Stripe** for subscription billing and overage charges
- **Supabase** stores subscription status and usage counters
- **Webhook handlers** sync payment state with user profiles

### 5.2 Database Schema (Future Addition)

```sql
-- Add to profiles table
ALTER TABLE public.profiles 
ADD COLUMN subscription_tier TEXT NOT NULL DEFAULT 'free' 
  CHECK (subscription_tier IN ('free', 'creator', 'studio', 'enterprise'));

ALTER TABLE public.profiles 
ADD COLUMN stripe_customer_id TEXT,
ADD COLUMN stripe_subscription_id TEXT,
ADD COLUMN subscription_expires_at TIMESTAMPTZ;

-- Usage tracking (for overage billing)
CREATE TABLE public.usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    generation_type TEXT NOT NULL CHECK (generation_type IN ('initial', 'patch', 'debug')),
    tokens_used INT NOT NULL,
    cost_usd DECIMAL(10, 6) NOT NULL,
    model_used TEXT NOT NULL,
    quality_setting TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 6. Growth & Expansion

### 6.1 Post-MVP Revenue Opportunities
| Feature | Model |
|---------|-------|
| AI Sprite Generation | Pay-per-image ($0.02/image) |
| Custom Audio Stems | Pay-per-generation ($0.05/audio) |
| Priority Queue | $4.99/mo add-on for faster generation |
| Marketplace | Revenue share on asset packs (20% commission) |
| White-Label | Enterprise custom deployment |

### 6.2 Key Metrics to Track
- **Free-to-Paid Conversion Rate** (target: 5-8%)
- **Monthly Churn** (target: < 5%)
- **Cost Per Acquisition** (target: < $15)
- **Lifetime Value** (target: > $120)
- **Gross Margin** (target: > 70%)

---

## 7. Competitive Positioning

| Platform | Price | Code Required | Asset Generation | Our Advantage |
|----------|-------|---------------|------------------|---------------|
| **GameForge AI** | Freemium | No | Kenney + Procedural | Fastest time-to-play, self-healing |
| **Lovable** | Freemium | No | AI-generated | We focus specifically on games |
| **GDevelop** | Free | Visual scripting | Manual import | Zero learning curve with NL prompts |
| **Construct 3** | $99/yr | Visual scripting | Manual import | AI-powered iteration |
| **ChatGPT + Code** | $20/mo | Yes | Manual | Integrated pipeline, no coding needed |

---

## 8. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| API cost spikes | Deterministic Asset Mapper, aggressive caching, fallback to free models |
| Low conversion | Generous free tier, watermark viral loop, showcase success stories |
| API provider changes | Multi-provider architecture, easy model swapping via admin portal |
| Abuse/spam | Rate limiting, captcha on free tier, manual review for published games |

---

## 9. MVP Launch Strategy

### Phase 1 (Week 1-2): Free Tier Only
- Gather user feedback
- Optimize generation pipeline
- Build community

### Phase 2 (Week 3-4): Introduce Creator Tier
- Stripe integration
- Remove watermark feature
- ZIP/GitHub export

### Phase 3 (Month 2+): Studio & Enterprise
- Team collaboration
- Custom domains
- White-label options

---

*Document Version: 1.0*  
*Last Updated: 2026-09-10*
