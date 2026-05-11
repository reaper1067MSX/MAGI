import { describe, it, expect, vi } from 'vitest';
import { loadConfig, RalphConfigSchema } from '../index.js';
import * as fs from 'node:fs/promises';

vi.mock('node:fs/promises');

describe('Config Loader', () => {
  it('should load default config if file is missing', async () => {
    vi.mocked(fs.readFile).mockRejectedValue({ code: 'ENOENT' });

    const config = await loadConfig('non-existent.json');
    expect(config.defaultAgent).toBe('gemini-cli');
    expect(config.stateDirectory).toBe('.ralph');
  });

  it('should validate valid config', () => {
    const validConfig = {
      agents: [{ name: 'custom', type: 'openai' }],
      defaultAgent: 'custom'
    };
    const result = RalphConfigSchema.safeParse(validConfig);
    expect(result.success).toBe(true);
  });

  it('should fail on invalid agent type', () => {
    const invalidConfig = {
      agents: [{ name: 'bad', type: 'unknown' }],
      defaultAgent: 'bad'
    };
    const result = RalphConfigSchema.safeParse(invalidConfig);
    expect(result.success).toBe(false);
  });
});
