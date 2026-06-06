import { Injectable } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";

export type AiProvider = "openai" | "groq";

export interface AiModelCost {
  inputPerMillionTokensUsd: number;
  outputPerMillionTokensUsd: number;
}

export interface AiProviderOption {
  provider: AiProvider;
  model: string;
  cost: AiModelCost;
}

export interface ActiveAiProvider extends AiProviderOption {
  maxTokens: number;
  temperature: number;
}

@Injectable()
export class AiConfigService {
  constructor(private readonly configService: ConfigService) {}

  getActiveProvider(): ActiveAiProvider {
    const provider = this.getProvider();
    const option = this.getProviderOption(provider);

    return {
      ...option,
      maxTokens: this.getNumber("AI_MAX_TOKENS", 700),
      temperature: this.getNumber("AI_TEMPERATURE", 0.2),
    };
  }

  getProviderOptions(): AiProviderOption[] {
    return [this.getProviderOption("openai"), this.getProviderOption("groq")];
  }

  estimateCostUsd(inputTokens: number, outputTokens: number) {
    const { cost } = this.getActiveProvider();

    return (
      (inputTokens / 1_000_000) * cost.inputPerMillionTokensUsd +
      (outputTokens / 1_000_000) * cost.outputPerMillionTokensUsd
    );
  }

  getApiKey(provider: AiProvider) {
    const envKey = provider === "openai" ? "OPENAI_API_KEY" : "GROQ_API_KEY";
    const apiKey = this.configService.get<string>(envKey)?.trim();

    if (!apiKey) {
      throw new Error(`${envKey} is required when AI_PROVIDER=${provider}`);
    }

    return apiKey;
  }

  private getProvider(): AiProvider {
    const provider = (
      this.configService.get<string>("AI_PROVIDER") ?? "openai"
    ).toLowerCase();

    if (provider === "openai" || provider === "groq") {
      return provider;
    }

    throw new Error("AI_PROVIDER must be either openai or groq");
  }

  private getProviderOption(provider: AiProvider): AiProviderOption {
    if (provider === "openai") {
      return {
        provider,
        model: this.getString("OPENAI_MODEL", "gpt-4o-mini"),
        cost: {
          inputPerMillionTokensUsd: this.getNumber(
            "OPENAI_INPUT_COST_PER_1M",
            0.15,
          ),
          outputPerMillionTokensUsd: this.getNumber(
            "OPENAI_OUTPUT_COST_PER_1M",
            0.6,
          ),
        },
      };
    }

    return {
      provider,
      model: this.getString(
        "GROQ_MODEL",
        "meta-llama/llama-4-scout-17b-16e-instruct",
      ),
      cost: {
        inputPerMillionTokensUsd: this.getNumber(
          "GROQ_INPUT_COST_PER_1M",
          0.11,
        ),
        outputPerMillionTokensUsd: this.getNumber(
          "GROQ_OUTPUT_COST_PER_1M",
          0.34,
        ),
      },
    };
  }

  private getString(key: string, fallback: string) {
    return this.configService.get<string>(key)?.trim() || fallback;
  }

  private getNumber(key: string, fallback: number) {
    const rawValue = this.configService.get<string>(key)?.trim();
    if (!rawValue) {
      return fallback;
    }

    const value = Number(rawValue);
    if (!Number.isFinite(value) || value < 0) {
      throw new Error(`${key} must be a non-negative number`);
    }

    return value;
  }
}
