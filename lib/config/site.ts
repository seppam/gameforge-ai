export const siteConfig = {
  name: "GameForge AI",
  description:
    "Transform natural language prompts into interactive, fully playable 2D web games in real-time.",
  url: "https://gameforge.ai",
  ogImage: "https://gameforge.ai/og.jpg",
  links: {
    github: "https://github.com/seppam/gameforge-ai",
    docs: "https://gameforge.ai/docs",
  },
} as const;

export const routeConfig = {
  public: ["/", "/login", "/register", "/play/[slug]"],
  auth: ["/dashboard", "/settings", "/studio/[gameId]"],
  admin: ["/admin/llm-config"],
} as const;

export const apiConfig = {
  version: "v1",
  basePath: "/api/v1",
  endpoints: {
    generate: "/generate",
    patch: "/patch",
    debug: "/debug",
    export: {
      zip: "/export/zip",
      github: "/export/github",
    },
    admin: {
      llm: "/admin/llm",
    },
  },
} as const;
