import { Injectable, ServiceUnavailableException } from "@nestjs/common";
import Groq from "groq-sdk";
import OpenAI from "openai";
import { AiConfigService, AiProvider } from "./ai-config.service";

interface GenerateTextOptions {
  prompt: string;
  systemPrompt?: string;
}

interface AiUsage {
  inputTokens: number;
  outputTokens: number;
  estimatedCostUsd: number;
}

export interface AiTextResult {
  provider: AiProvider;
  model: string;
  text: string;
  usage: AiUsage;
}

const DEFAULT_SYSTEM_PROMPT =
  "You are KajuPilot's private AI helper for a cashew trading business. Be concise, practical, and preserve the user's numbers exactly.";

@Injectable()
export class AiService {
  private openaiClient?: OpenAI;
  private groqClient?: Groq;

  constructor(private readonly aiConfig: AiConfigService) {}

  getProviderSummary() {
    return {
      active: this.aiConfig.getActiveProvider(),
      options: this.aiConfig.getProviderOptions(),
    };
  }

  async generateText(options: GenerateTextOptions): Promise<AiTextResult> {
    const activeProvider = this.aiConfig.getActiveProvider();

    if (activeProvider.provider === "openai") {
      return this.generateWithOpenAi(options);
    }

    return this.generateWithGroq(options);
  }

  private async generateWithOpenAi(
    options: GenerateTextOptions,
  ): Promise<AiTextResult> {
    const activeProvider = this.aiConfig.getActiveProvider();

    try {
      const completion = await this.getOpenAiClient().chat.completions.create({
        model: activeProvider.model,
        messages: this.toMessages(options),
        max_tokens: activeProvider.maxTokens,
        temperature: activeProvider.temperature,
      });

      const inputTokens = completion.usage?.prompt_tokens ?? 0;
      const outputTokens = completion.usage?.completion_tokens ?? 0;

      return {
        provider: activeProvider.provider,
        model: activeProvider.model,
        text: completion.choices[0]?.message?.content?.trim() ?? "",
        usage: {
          inputTokens,
          outputTokens,
          estimatedCostUsd: this.aiConfig.estimateCostUsd(
            inputTokens,
            outputTokens,
          ),
        },
      };
    } catch (error) {
      throw new ServiceUnavailableException(
        this.toProviderError("OpenAI", error),
      );
    }
  }

  private async generateWithGroq(
    options: GenerateTextOptions,
  ): Promise<AiTextResult> {
    const activeProvider = this.aiConfig.getActiveProvider();

    try {
      const completion = await this.getGroqClient().chat.completions.create({
        model: activeProvider.model,
        messages: this.toMessages(options),
        max_tokens: activeProvider.maxTokens,
        temperature: activeProvider.temperature,
      });

      const inputTokens = completion.usage?.prompt_tokens ?? 0;
      const outputTokens = completion.usage?.completion_tokens ?? 0;

      return {
        provider: activeProvider.provider,
        model: activeProvider.model,
        text: completion.choices[0]?.message?.content?.trim() ?? "",
        usage: {
          inputTokens,
          outputTokens,
          estimatedCostUsd: this.aiConfig.estimateCostUsd(
            inputTokens,
            outputTokens,
          ),
        },
      };
    } catch (error) {
      throw new ServiceUnavailableException(
        this.toProviderError("Groq", error),
      );
    }
  }

  private getOpenAiClient() {
    this.openaiClient ??= new OpenAI({
      apiKey: this.aiConfig.getApiKey("openai"),
    });

    return this.openaiClient;
  }

  private getGroqClient() {
    this.groqClient ??= new Groq({
      apiKey: this.aiConfig.getApiKey("groq"),
    });

    return this.groqClient;
  }

  private toMessages(options: GenerateTextOptions) {
    return [
      {
        role: "system" as const,
        content: options.systemPrompt ?? DEFAULT_SYSTEM_PROMPT,
      },
      {
        role: "user" as const,
        content: options.prompt,
      },
    ];
  }

  private toProviderError(providerName: string, error: unknown) {
    if (error instanceof Error) {
      return `${providerName} request failed: ${error.message}`;
    }

    return `${providerName} request failed`;
  }
}
