import type { AgentAdapter, AgentContext, IterationResult } from '../types/index.js';

export abstract class BaseAgent implements AgentAdapter {
  constructor(public name: string) {}

  abstract invoke(prompt: string, context: AgentContext): Promise<IterationResult>;

  protected createSuccessResult(message: string, nextStep?: string): IterationResult {
    return { success: true, message, nextStep };
  }

  protected createErrorResult(message: string, error?: Error): IterationResult {
    return { success: false, message, error };
  }
}
