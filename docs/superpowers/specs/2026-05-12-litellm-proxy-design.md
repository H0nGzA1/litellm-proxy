# LiteLLM Proxy — Design Spec

## Purpose

A local LiteLLM-based proxy gateway that enables per-session, per-project model switching in Claude Code. Route complex tasks to GPT-5, simple tasks to domestic/cheaper models — all via `/model` command.

## Architecture

```
Claude Code Terminal 1 ($env:MODEL=haiku)  ──┐
Claude Code Terminal 2 ($env:MODEL=sonnet) ──┤──→ LiteLLM (localhost:4000) ──→ Relay APIs
Claude Code Terminal 3 ($env:MODEL=gpt5)   ──┘         │
                                                  ┌────┴────┐
                                                  │ GPT-5   │ ← another-relay.com
                                                  │ Sonnet  │ ← your-relay.com
                                                  │ Haiku   │ ← your-relay.com
                                                  │ DeepSeek│ ← deepseek-relay.com
                                                  │ Qwen    │ ← qwen-relay.com
                                                  └─────────┘
```

- **LiteLLM** translates Anthropic Messages API → OpenAI Chat Completions for non-Anthropic backends
- All backends are relay APIs (中转), not official endpoints
- Model names in Claude Code are user-defined aliases, decoupled from relay model IDs

## Project Structure

```
D:\AVC-PROJECT\litellm-proxy\
  litellm_config.yaml     ← All model definitions + routing
  .env                    ← API keys (gitignored)
  .env.example            ← Key template (committed)
  start.ps1               ← One-click: start proxy + launch multi-model terminals
  start-proxy-only.ps1    ← Start proxy only
  docker-compose.yml      ← Docker deployment
  .gitignore
```

## Configuration Design

### litellm_config.yaml

```yaml
general_settings:
  master_key: sk-proxy-master-key

model_list:
  - model_name: haiku               # /model haiku in Claude Code
    litellm_params:
      model: openai/<relay-model-id>
      api_base: ${RELAY_BASE_URL}
      api_key: ${RELAY_KEY}

  - model_name: sonnet              # /model sonnet
    litellm_params:
      model: openai/<relay-model-id>
      api_base: ${RELAY_BASE_URL}
      api_key: ${RELAY_KEY}

  - model_name: gpt5                # /model gpt5
    litellm_params:
      model: openai/<relay-model-id>
      api_base: ${GPT_RELAY_BASE_URL}
      api_key: ${GPT_RELAY_KEY}
```

### .env

```env
RELAY_BASE_URL=https://your-relay.com/v1
RELAY_KEY=sk-your-key
GPT_RELAY_BASE_URL=https://another-relay.com/v1
GPT_RELAY_KEY=sk-your-key
```

## Model Priority (3-tier)

| Priority | Mechanism | Scope |
|----------|-----------|-------|
| 1 (highest) | `/model <name>` in Claude Code | Current session |
| 2 | `$env:ANTHROPIC_DEFAULT_MODEL` | Current terminal |
| 3 (lowest) | `.claude/settings.json` in project | All sessions in project |

## Deployment Modes

### Docker (recommended for daily use)
```bash
docker compose up -d
```

### Python (for debugging)
```bash
pip install litellm[proxy]
litellm --config litellm_config.yaml --port 4000
```

### One-click script
```powershell
.\start.ps1  # Docker + launch 3 terminals with different models
```

## Per-Project Integration

Each project adds to `.claude/settings.local.json`:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:4000/v1",
    "ANTHROPIC_API_KEY": "sk-proxy-master-key"
  }
}
```

## Error Handling

- Relay API unreachable → LiteLLM returns standard Anthropic error, Claude Code surfaces it
- Invalid model name → LiteLLM returns 400 with available model list
- Master key mismatch → 401, check .env and settings.local.json alignment

## Scope

- **In**: LiteLLM config, Docker Compose, launch scripts, .env management
- **Out**: Web admin UI, multi-user management, usage tracking, billing
