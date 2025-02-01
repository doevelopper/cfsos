from openai import OpenAI

client = OpenAI(
  base_url = "https://integrate.api.nvidia.com/v1",
  api_key = "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"
)

completion = client.chat.completions.create(
  model="deepseek-ai/deepseek-r1",
  messages=[{"role":"user","content":"I would like you to help design  a secure design applicable to achieve a most secured embedded Linux system that runs on Raspberry PI 3.  The purpose is to use Raspberry PI 3 as   robotic/rover/unmanned system's brain. Kindly use mermaid syntax do design High-Level Architecture Diagram"}],
  temperature=0.6,
  top_p=0.7,
  max_tokens=4096,
  stream=True
)

for chunk in completion:
  if chunk.choices[0].delta.content is not None:
    print(chunk.choices[0].delta.content, end="")

