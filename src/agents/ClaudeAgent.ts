import { BaseAgent } from './BaseAgent.js';
import type { AgentContext, IterationResult } from '../types/index.js';
import Anthropic from '@anthropic-ai/sdk';

export class ClaudeAgent extends BaseAgent {
  private apiKey: string;
  private modelName: string;

  constructor(apiKey?: string, modelName: string = 'claude-3-5-sonnet-20241022') {
    super('claude');
    this.apiKey = apiKey || process.env.ANTHROPIC_API_KEY || '';
    this.modelName = modelName;
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    try {
      if (!this.apiKey) {
        return this.createErrorResult('ANTHROPIC_API_KEY is missing.');
      }

      const ai = new Anthropic({ apiKey: this.apiKey });
      const response = await ai.messages.create({
        model: this.modelName,
        max_tokens: 4096,
        messages: [{ role: 'user', content: prompt }]
      });

      const textBlock = response.content.find(block => block.type === 'text');
      const responseText = textBlock && textBlock.type === 'text' ? textBlock.text : '';

      return this.createSuccessResult(`Claude (${this.modelName}) processed the iteration.`, responseText);
    } catch (error) {
      return this.createErrorResult(`Claude API error: ${(error as Error).message}`, error as Error);
    }
  }
}
