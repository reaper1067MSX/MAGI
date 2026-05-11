import { BaseAgent } from './BaseAgent.js';
import type { AgentContext, IterationResult } from '../types/index.js';
import { GoogleGenerativeAI } from '@google/generative-ai';

export class GeminiAgent extends BaseAgent {
  private apiKey: string;
  private modelName: string;

  constructor(apiKey?: string, modelName: string = 'gemini-2.5-pro') {
    super('gemini');
    this.apiKey = apiKey || process.env.GEMINI_API_KEY || '';
    this.modelName = modelName;
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    try {
      if (!this.apiKey) {
         return this.createErrorResult('GEMINI_API_KEY is missing.');
      }

      const ai = new GoogleGenerativeAI(this.apiKey);
      const model = ai.getGenerativeModel({ model: this.modelName });
      const result = await model.generateContent(prompt);
      const response = result.response.text();

      return this.createSuccessResult(`Gemini (${this.modelName}) processed the iteration.`, response);
    } catch (error) {
      return this.createErrorResult(`Gemini API error: ${(error as Error).message}`, error as Error);
    }
  }
}
