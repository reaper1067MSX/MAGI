import { z } from 'zod';
import type { RalphConfig, AgentConfig } from '../types/index.js';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';

export const AgentConfigSchema = z.object({
  name: z.string(),
  type: z.enum(['gemini', 'openai', 'ollama', 'claude']),
  model: z.string().optional(),
  endpoint: z.string().url().optional(),
  apiKey: z.string().optional()
});

export const RalphConfigSchema = z.object({
  agents: z.array(AgentConfigSchema),
  defaultAgent: z.string(),
  stateDirectory: z.string().default('.ralph')
});

export async function loadConfig(configPath: string): Promise<RalphConfig> {
  try {
    const data = await fs.readFile(configPath, 'utf8');
    const parsed = JSON.parse(data);
    return RalphConfigSchema.parse(parsed);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
      // Return default config
      return {
        agents: [
          {
            name: 'gemini-cli',
            type: 'gemini'
          }
        ],
        defaultAgent: 'gemini-cli',
        stateDirectory: '.ralph'
      };
    }
    throw error;
  }
}
