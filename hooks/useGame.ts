"use client";

import { useState, useCallback } from "react";
import type { Game } from "@/types/game";

interface UseGameReturn {
  game: Game | null;
  isLoading: boolean;
  error: Error | null;
  loadGame: (gameId: string) => Promise<void>;
  createGame: (prompt: string) => Promise<void>;
}

export function useGame(): UseGameReturn {
  const [game, setGame] = useState<Game | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const loadGame = useCallback(async (gameId: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await fetch(`/api/v1/games/${gameId}`);
      if (!response.ok) throw new Error("Failed to load game");
      const data = await response.json();
      setGame(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
    } finally {
      setIsLoading(false);
    }
  }, []);

  const createGame = useCallback(async (prompt: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await fetch("/api/v1/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt }),
      });
      if (!response.ok) throw new Error("Failed to create game");
      const data = await response.json();
      setGame(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error("Unknown error"));
    } finally {
      setIsLoading(false);
    }
  }, []);

  return { game, isLoading, error, loadGame, createGame };
}
