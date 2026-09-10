export interface Game {
  id: string;
  user_id: string;
  title: string;
  slug: string;
  description: string | null;
  genre: string;
  is_published: boolean;
  plays_count: number;
  thumbnail_url: string | null;
  thumbnail_generated_at: string | null;
  is_watermarked: boolean;
  active_version_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface GameVersion {
  id: string;
  game_id: string;
  version_number: number;
  source_code: string;
  game_spec: Record<string, unknown>;
  asset_manifest: Record<string, unknown>;
  change_summary: string | null;
  created_by_agent: "coder" | "debugger" | "manual";
  is_fallback_used: boolean;
  created_at: string;
}

export interface PromptLog {
  id: string;
  game_id: string;
  user_id: string;
  role: "user" | "assistant" | "system";
  content: string;
  tokens_used: number;
  model_used: string;
  was_fallback: boolean;
  fallback_reason: string | null;
  execution_time_ms: number;
  created_at: string;
}

export interface Profile {
  id: string;
  email: string;
  full_name: string | null;
  avatar_url: string | null;
  role: "creator" | "admin";
  daily_prompt_count: number;
  daily_prompt_limit: number;
  quality_preference: "fast" | "balanced" | "best";
  github_access_token: string | null;
  subscription_tier: "free" | "creator" | "studio" | "enterprise";
  stripe_customer_id: string | null;
  stripe_subscription_id: string | null;
  subscription_expires_at: string | null;
  created_at: string;
  updated_at: string;
}
