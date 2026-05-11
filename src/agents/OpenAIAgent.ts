import { BaseAgent } from './BaseAgent.js';
import type { AgentContext, IterationResult } from '../types/index.js';

export class OpenAIAgent extends BaseAgent {
  constructor(private apiKey?: string, private model: string = 'gpt-4') {
    super('openai');
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    // Placeholder for actual API call
    return this.createSuccessResult(`OpenAI (${this.model}) processed the iteration`, 'Next step: Verify implementation.');
  }
}

export class OllamaAgent extends BaseAgent {
  constructor(private endpoint: string = 'http://localhost:11434', private model: string = 'llama3') {
    super('ollama');
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    // Placeholder for actual API call
    return this.createSuccessResult(`Ollama (${this.model}) processed the iteration`, 'Next step: Run tests.');
  }
}
