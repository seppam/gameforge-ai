export const GAME_GENRES = [
  "platformer",
  "shooter",
  "puzzle",
  "rpg",
  "arcade",
  "endless",
] as const;

export type GameGenre = (typeof GAME_GENRES)[number];

export const ENTITY_TYPES = [
  "player",
  "enemy",
  "obstacle",
  "collectible",
  "projectile",
  "platform",
  "background",
] as const;

export type EntityType = (typeof ENTITY_TYPES)[number];

export const AUDIO_EVENT_TYPES = [
  "jump",
  "shoot",
  "explosion",
  "collect",
  "hit",
  "gameOver",
  "win",
  "background",
] as const;

export type AudioEventType = (typeof AUDIO_EVENT_TYPES)[number];

export const DEFAULT_GAME_CONFIG = {
  width: 800,
  height: 600,
  physics: "arcade",
  gravity: { x: 0, y: 300 },
  lives: 3,
} as const;
