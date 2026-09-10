import { z } from "zod";

export const GameSpecSchema = z.object({
  title: z.string().describe("Game title"),
  genre: z.enum(["platformer", "shooter", "puzzle", "rpg", "arcade", "endless"]),
  description: z.string().describe("Brief game description"),
  entities: z
    .array(
      z.object({
        name: z.string(),
        type: z.enum([
          "player",
          "enemy",
          "obstacle",
          "collectible",
          "projectile",
          "platform",
          "background",
        ]),
        tags: z.array(z.string()).optional(),
        properties: z
          .object({
            health: z.number().optional(),
            speed: z.number().optional(),
            damage: z.number().optional(),
            color: z.string().optional(),
            width: z.number().optional(),
            height: z.number().optional(),
          })
          .optional(),
      })
    )
    .describe("Game entities and their properties"),
  mechanics: z
    .object({
      controls: z.enum(["keyboard", "mouse", "touch", "gamepad"]),
      physics: z.enum(["arcade", "matter"]).default("arcade"),
      scoring: z.boolean().default(false),
      lives: z.number().default(3),
      winCondition: z.string(),
      loseCondition: z.string(),
    })
    .describe("Core game mechanics"),
  audioEvents: z
    .array(
      z.object({
        name: z.string(),
        type: z.enum([
          "jump",
          "shoot",
          "explosion",
          "collect",
          "hit",
          "gameOver",
          "win",
          "background",
        ]),
        trigger: z.string().describe("When this sound plays"),
      })
    )
    .optional(),
  difficulty: z.enum(["easy", "normal", "hard"]).default("normal"),
});

export type GameSpec = z.infer<typeof GameSpecSchema>;
