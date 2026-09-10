import { z } from "zod";

export const LLMConfigSchema = z.object({
  id: z.string().uuid(),
  agent_role: z.enum([
    "spec_agent",
    "coder_agent",
    "debug_agent",
  ]),
  primary_provider: z.enum(["anthropic", "openai", "deepseek", "gemini"]),
  primary_model_name: z.string(),
  fallback_provider: z
    .enum(["anthropic", "openai", "deepseek", "gemini"])
    .nullable(),
  fallback_model_name: z.string().nullable(),
  is_primary_quota_exhausted: z.boolean().default(false),
  exhaustion_detected_at: z.string().datetime().nullable(),
  temperature: z.number().min(0).max(2).default(0.2),
  max_tokens: z.number().default(4096),
  is_active: z.boolean().default(true),
  updated_by: z.string().uuid().nullable(),
  updated_at: z.string().datetime(),
});

export type LLMConfig = z.infer<typeof LLMConfigSchema>;
