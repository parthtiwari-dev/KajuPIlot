import { ConfigService } from "@nestjs/config";
import { AiConfigService } from "./ai-config.service";

describe("AiConfigService", () => {
  it("defaults to OpenAI GPT-4o mini", () => {
    const service = new AiConfigService(new ConfigService({}));

    expect(service.getActiveProvider()).toMatchObject({
      provider: "openai",
      model: "gpt-4o-mini",
      cost: {
        inputPerMillionTokensUsd: 0.15,
        outputPerMillionTokensUsd: 0.6,
      },
    });
  });

  it("switches to Groq from one env value", () => {
    const service = new AiConfigService(
      new ConfigService({
        AI_PROVIDER: "groq",
        GROQ_MODEL: "llama-3.3-70b-versatile",
        GROQ_INPUT_COST_PER_1M: "0.59",
        GROQ_OUTPUT_COST_PER_1M: "0.79",
      }),
    );

    expect(service.getActiveProvider()).toMatchObject({
      provider: "groq",
      model: "llama-3.3-70b-versatile",
      cost: {
        inputPerMillionTokensUsd: 0.59,
        outputPerMillionTokensUsd: 0.79,
      },
    });
  });

  it("estimates active provider token cost", () => {
    const service = new AiConfigService(
      new ConfigService({
        OPENAI_INPUT_COST_PER_1M: "0.15",
        OPENAI_OUTPUT_COST_PER_1M: "0.60",
      }),
    );

    expect(service.estimateCostUsd(1_000_000, 1_000_000)).toBe(0.75);
  });

  it("rejects invalid provider switches", () => {
    const service = new AiConfigService(
      new ConfigService({
        AI_PROVIDER: "local",
      }),
    );

    expect(() => service.getActiveProvider()).toThrow(
      "AI_PROVIDER must be either openai or groq",
    );
  });
});
