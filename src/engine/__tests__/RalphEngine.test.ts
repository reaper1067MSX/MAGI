import { describe, it, expect, vi, beforeEach } from 'vitest';
import { RalphEngine } from '../RalphEngine.js';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';

vi.mock('node:fs/promises');

describe('RalphEngine', () => {
  const mockConfig = {
    agents: [{ name: 'test-agent', type: 'gemini' as const }],
    defaultAgent: 'test-agent',
    stateDirectory: '.ralph-test'
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should build prompt correctly from guardrails and progress', async () => {
    const engine = new RalphEngine(mockConfig);
    const mockAgent = {
      name: 'test-agent',
      invoke: vi.fn().mockResolvedValue({ success: true, message: 'Done' })
    };

    // Mock file reads
    vi.mocked(fs.readFile).mockImplementation((filePath) => {
      const fileName = path.basename(filePath as string);
      if (fileName === 'guardrails.md') return Promise.resolve('KEEP IT SIMPLE');
      if (fileName === 'progress.md') return Promise.resolve('STEP 1 DONE');
      return Promise.reject(new Error('File not found'));
    });

    await engine.runIteration(mockAgent, 'test-task');

    expect(mockAgent.invoke).toHaveBeenCalledWith(
      expect.stringContaining('KEEP IT SIMPLE'),
      expect.any(Object)
    );
    expect(mockAgent.invoke).toHaveBeenCalledWith(
      expect.stringContaining('STEP 1 DONE'),
      expect.any(Object)
    );
  });

  it('should update progress on successful iteration', async () => {
    const engine = new RalphEngine(mockConfig);
    const mockAgent = {
      name: 'test-agent',
      invoke: vi.fn().mockResolvedValue({ 
        success: true, 
        message: 'Success!', 
        nextStep: 'NEW PROGRESS' 
      })
    };

    await engine.runIteration(mockAgent, 'test-task');

    expect(fs.writeFile).toHaveBeenCalledWith(
      expect.stringContaining('progress.md'),
      'NEW PROGRESS'
    );
  });
});
