import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
      },
    ],
  },
  // Enable server components for streaming
  experimental: {
    serverComponentsExternalPackages: ["@supabase/supabase-js"],
  },
};

export default nextConfig;
