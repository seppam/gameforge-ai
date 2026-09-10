-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles table (extends Supabase Auth)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'creator' CHECK (role IN ('creator', 'admin')),
    
    -- Generation Quotas & Usage
    daily_prompt_count INT NOT NULL DEFAULT 0,
    daily_prompt_limit INT NOT NULL DEFAULT 10,
    
    -- Quality Preference (user-facing: Fast / Balanced / Best)
    quality_preference TEXT NOT NULL DEFAULT 'balanced' 
        CHECK (quality_preference IN ('fast', 'balanced', 'best')),
    
    -- GitHub Integration (encrypted at application layer before storage)
    github_access_token TEXT,
    
    -- Subscription & Billing (Phase 2+)
    subscription_tier TEXT NOT NULL DEFAULT 'free' 
        CHECK (subscription_tier IN ('free', 'creator', 'studio', 'enterprise')),
    stripe_customer_id TEXT,
    stripe_subscription_id TEXT,
    subscription_expires_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Games table
CREATE TABLE public.games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Untitled Game',
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    genre TEXT NOT NULL DEFAULT 'Arcade',
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    plays_count BIGINT NOT NULL DEFAULT 0,
    
    -- Thumbnail (auto-captured from Phaser canvas or placeholder)
    thumbnail_url TEXT,
    thumbnail_generated_at TIMESTAMPTZ,
    
    -- Watermark (free tier only)
    is_watermarked BOOLEAN NOT NULL DEFAULT TRUE,
    
    active_version_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_games_user_id ON public.games(user_id);
CREATE INDEX idx_games_slug ON public.games(slug);

-- 3. Game versions table
CREATE TABLE public.game_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
    version_number INT NOT NULL,
    source_code TEXT NOT NULL,
    game_spec JSONB NOT NULL DEFAULT '{}'::jsonb,
    asset_manifest JSONB NOT NULL DEFAULT '{}'::jsonb,
    change_summary TEXT,
    created_by_agent TEXT NOT NULL DEFAULT 'coder' CHECK (created_by_agent IN ('coder', 'debugger', 'manual')),
    is_fallback_used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_game_version UNIQUE (game_id, version_number)
);

CREATE INDEX idx_game_versions_game_id ON public.game_versions(game_id);

-- 4. Prompt logs table
CREATE TABLE public.prompt_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    tokens_used INT DEFAULT 0,
    model_used TEXT NOT NULL,
    was_fallback BOOLEAN NOT NULL DEFAULT FALSE,
    fallback_reason TEXT,
    execution_time_ms INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prompt_logs_game_id ON public.prompt_logs(game_id);

-- 5. Community examples table
CREATE TABLE public.community_examples (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES public.games(id) ON DELETE SET NULL,
    prompt_text TEXT NOT NULL,
    genre TEXT,
    description TEXT,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    times_used INT NOT NULL DEFAULT 0,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_community_examples_featured ON public.community_examples(is_featured, display_order);

-- 6. Usage logs table (Phase 2+ Billing)
CREATE TABLE public.usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    game_id UUID REFERENCES public.games(id),
    generation_type TEXT NOT NULL CHECK (generation_type IN ('initial', 'patch', 'debug')),
    tokens_used INT NOT NULL,
    cost_usd DECIMAL(10, 6) NOT NULL,
    model_used TEXT NOT NULL,
    quality_setting TEXT NOT NULL,
    was_fallback BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_usage_logs_user_id ON public.usage_logs(user_id);
CREATE INDEX idx_usage_logs_created_at ON public.usage_logs(created_at);

-- 7. LLM configs table
CREATE TABLE public.llm_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_role TEXT NOT NULL UNIQUE CHECK (agent_role IN ('spec_agent', 'coder_agent', 'debug_agent')),
    
    primary_provider TEXT NOT NULL CHECK (primary_provider IN ('anthropic', 'openai', 'deepseek', 'gemini')),
    primary_model_name TEXT NOT NULL,
    
    fallback_provider TEXT CHECK (fallback_provider IN ('anthropic', 'openai', 'deepseek', 'gemini')),
    fallback_model_name TEXT,
    
    is_primary_quota_exhausted BOOLEAN NOT NULL DEFAULT FALSE,
    exhaustion_detected_at TIMESTAMPTZ,
    
    temperature NUMERIC(3, 2) NOT NULL DEFAULT 0.20,
    max_tokens INT NOT NULL DEFAULT 4096,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prompt_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.llm_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_examples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Profiles
CREATE POLICY "Users can view and edit own profile" 
ON public.profiles FOR ALL 
USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" 
ON public.profiles FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));

-- Games
CREATE POLICY "Users can manage own games" 
ON public.games FOR ALL 
USING (auth.uid() = user_id);

CREATE POLICY "Public can view published games" 
ON public.games FOR SELECT 
USING (is_published = TRUE);

-- Game Versions
CREATE POLICY "Users can manage own game versions" 
ON public.game_versions FOR ALL 
USING (EXISTS (SELECT 1 FROM public.games WHERE games.id = game_versions.game_id AND games.user_id = auth.uid()));

CREATE POLICY "Public can view published game versions" 
ON public.game_versions FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.games WHERE games.id = game_versions.game_id AND games.is_published = TRUE));

-- Prompt Logs
CREATE POLICY "Users can view own prompt history" 
ON public.prompt_logs FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "System and users can insert prompt logs" 
ON public.prompt_logs FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- LLM Configs
CREATE POLICY "Internal service read llm configs" 
ON public.llm_configs FOR SELECT 
TO authenticated 
USING (TRUE);

CREATE POLICY "Admins have full control over llm configs" 
ON public.llm_configs FOR ALL 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));

-- Community Examples
CREATE POLICY "Public can view community examples" 
ON public.community_examples FOR SELECT 
TO authenticated 
USING (TRUE);

CREATE POLICY "Admins can manage community examples" 
ON public.community_examples FOR ALL 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));

-- Usage Logs
CREATE POLICY "Users can view own usage logs" 
ON public.usage_logs FOR SELECT 
USING (auth.uid() = user_id);
