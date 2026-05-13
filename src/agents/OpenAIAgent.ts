import { BaseAgent } from './BaseAgent.js';
import type { AgentContext, IterationResult } from '../types/index.js';
import OpenAI from 'openai';

export class OpenAIAgent extends BaseAgent {
  private apiKey: string;
  private modelName: string;

  constructor(apiKey?: string, modelName: string = 'gpt-4o') {
    super('openai');
    this.apiKey = apiKey || process.env.OPENAI_API_KEY || '';
    this.modelName = modelName;
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    try {
      if (!this.apiKey) {
         return this.createErrorResult('OPENAI_API_KEY is missing.');
      }

      const ai = new OpenAI({ apiKey: this.apiKey });
      const response = await ai.chat.completions.create({
        model: this.modelName,
        messages: [{ role: 'user', content: prompt }],
      });

      const responseText = response.choices[0]?.message?.content || '';

      return this.createSuccessResult(`OpenAI (${this.modelName}) processed the iteration.`, responseText);
    } catch (error) {
      return this.createErrorResult(`OpenAI API error: ${(error as Error).message}`, error as Error);
    }
  }
}

export class OllamaAgent extends BaseAgent {
  constructor(private endpoint: string = 'http://localhost:11434', private model: string = 'llama3') {
    super('ollama');
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    try {
      const response = await fetch(`${this.endpoint}/api/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: this.model,
          prompt: prompt,
          stream: false
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return this.createSuccessResult(`Ollama (${this.model}) processed the iteration`, data.response);
    } catch (error) {
      return this.createErrorResult(`Ollama API error: ${(error as Error).message}`, error as Error);
    }
  }
}
