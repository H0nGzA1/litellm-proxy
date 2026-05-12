# LiteLLM Proxy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local LiteLLM proxy gateway at `D:\AVC-PROJECT\litellm-proxy\` that enables per-session model switching in Claude Code via `/model` command.

**Architecture:** Single LiteLLM instance exposes Anthropic-compatible API on `localhost:4000`. Model names in Claude Code map to relay API backends via `litellm_config.yaml`. Docker for daily use, Python direct for debugging, PowerShell scripts for one-click launch.

**Tech Stack:** LiteLLM (Docker image `ghcr.io/berriai/litellm:main-stable`), Docker Compose, PowerShell 5.1+

---

### Task 1: Project scaffolding — .gitignore and .env.example

**Files:**
- Create: `D:\AVC-PROJECT\litellm-proxy\.gitignore`
- Create: `D:\AVC-PROJECT\litellm-proxy\.env.example`

- [ ] **Step 1: Create .gitignore**

```gitignore
.env
```

- [ ] **Step 2: Create .env.example**

```env
# ========== Relay API Keys ==========
# Fill in your relay/base URLs and keys below.
# Duplicate the RELAY_KEY_* pattern for each relay provider.

# Relay provider A (e.g., your-relay.com)
RELAY_A_BASE_URL=https://your-relay.com/v1
RELAY_A_KEY=sk-your-key-here

# Relay provider B (e.g., another-relay.com)
RELAY_B_BASE_URL=https://another-relay.com/v1
RELAY_B_KEY=sk-your-key-here
```

- [ ] **Step 3: Commit**

```bash
cd D:/AVC-PROJECT/litellm-proxy
git add .gitignore .env.example
git commit -m "chore: add project scaffolding — gitignore and env template"
```

---

### Task 2: Create docker-compose.yml

**Files:**
- Create: `D:\AVC-PROJECT\litellm-proxy\docker-compose.yml`

- [ ] **Step 1: Create docker-compose.yml**

```yaml
services:
  litellm:
    image: ghcr.io/berriai/litellm:main-stable
    ports:
      - "4000:4000"
    volumes:
      - ./litellm_config.yaml:/app/config.yaml
      - ./.env:/app/.env
    command: ["--config", "/app/config.yaml", "--port", "4000"]
    restart: unless-stopped
```

- [ ] **Step 2: Commit**

```bash
cd D:/AVC-PROJECT/litellm-proxy
git add docker-compose.yml
git commit -m "feat: add docker-compose for LiteLLM proxy"
```

---

### Task 3: Create litellm_config.yaml

**Files:**
- Create: `D:\AVC-PROJECT\litellm-proxy\litellm_config.yaml`

- [ ] **Step 1: Create litellm_config.yaml**

```yaml
general_settings:
  master_key: sk-proxy-master-key

model_list:
  - model_name: haiku
    litellm_params:
      model: openai/${RELAY_A_HAIKU_MODEL_ID}
      api_base: ${RELAY_A_BASE_URL}
      api_key: ${RELAY_A_KEY}

  - model_name: sonnet
    litellm_params:
      model: openai/${RELAY_A_SONNET_MODEL_ID}
      api_base: ${RELAY_A_BASE_URL}
      api_key: ${RELAY_A_KEY}

  - model_name: gpt5
    litellm_params:
      model: openai/${RELAY_B_GPT5_MODEL_ID}
      api_base: ${RELAY_B_BASE_URL}
      api_key: ${RELAY_B_KEY}
```

- [ ] **Step 2: Commit**

```bash
cd D:/AVC-PROJECT/litellm-proxy
git add litellm_config.yaml
git commit -m "feat: add LiteLLM config with haiku/sonnet/gpt5 model routing"
```

---

### Task 4: Create start-proxy-only.ps1

**Files:**
- Create: `D:\AVC-PROJECT\litellm-proxy\start-proxy-only.ps1`

- [ ] **Step 1: Create start-proxy-only.ps1**

```powershell
Write-Host "Starting LiteLLM proxy..." -ForegroundColor Cyan
docker compose up -d
Start-Sleep -Seconds 3
Write-Host "Proxy running at http://localhost:4000" -ForegroundColor Green
Write-Host "Master key: sk-proxy-master-key" -ForegroundColor Yellow
```

- [ ] **Step 2: Commit**

```bash
cd D:/AVC-PROJECT/litellm-proxy
git add start-proxy-only.ps1
git commit -m "feat: add proxy-only startup script"
```

---

### Task 5: Create start.ps1 — one-click multi-session launcher

**Files:**
- Create: `D:\AVC-PROJECT\litellm-proxy\start.ps1`

- [ ] **Step 1: Create start.ps1**

```powershell
param(
    [string]$ProjectPath = ""
)

# Start proxy
Write-Host "Starting LiteLLM proxy..." -ForegroundColor Cyan
docker compose up -d
Start-Sleep -Seconds 3

# If no project path given, prompt user
if (-not $ProjectPath) {
    $ProjectPath = Read-Host "Enter project path (e.g., D:\AVC-PROJECT\pis-agent-admin-ui)"
}

Write-Host "Launching terminals with different models..." -ForegroundColor Cyan

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "`$env:ANTHROPIC_BASE_URL='http://localhost:4000/v1'; `$env:ANTHROPIC_API_KEY='sk-proxy-master-key'; `$env:ANTHROPIC_DEFAULT_MODEL='haiku'; cd '$ProjectPath'; Write-Host 'Model: haiku' -ForegroundColor Magenta; claude"
)

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "`$env:ANTHROPIC_BASE_URL='http://localhost:4000/v1'; `$env:ANTHROPIC_API_KEY='sk-proxy-master-key'; `$env:ANTHROPIC_DEFAULT_MODEL='sonnet'; cd '$ProjectPath'; Write-Host 'Model: sonnet' -ForegroundColor Magenta; claude"
)

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "`$env:ANTHROPIC_BASE_URL='http://localhost:4000/v1'; `$env:ANTHROPIC_API_KEY='sk-proxy-master-key'; `$env:ANTHROPIC_DEFAULT_MODEL='gpt5'; cd '$ProjectPath'; Write-Host 'Model: gpt5' -ForegroundColor Magenta; claude"
)

Write-Host "Done. 3 terminals launched with haiku / sonnet / gpt5." -ForegroundColor Green
```

- [ ] **Step 2: Commit**

```bash
cd D:/AVC-PROJECT/litellm-proxy
git add start.ps1
git commit -m "feat: add one-click multi-model terminal launcher"
```

---

### Task 6: Smoke test — Docker startup and health check

- [ ] **Step 1: Copy .env.example to .env (real keys required)**

```bash
cd D:/AVC-PROJECT/litellm-proxy
cp .env.example .env
# Edit .env with real relay API keys and model IDs
```

- [ ] **Step 2: Start Docker and verify it's running**

```bash
docker compose up -d
docker compose ps
```

Expected: litellm service status is `Up`.

- [ ] **Step 3: Test model list endpoint**

```bash
curl http://localhost:4000/v1/models -H "Authorization: Bearer sk-proxy-master-key"
```

Expected: JSON response listing haiku, sonnet, gpt5.

- [ ] **Step 4: Test chat completions**

```bash
curl -X POST http://localhost:4000/v1/chat/completions `
  -H "Authorization: Bearer sk-proxy-master-key" `
  -H "Content-Type: application/json" `
  -d '{"model":"haiku","messages":[{"role":"user","content":"hello"}]}'
```

Expected: valid chat completion response from relay backend.

- [ ] **Step 5: Cleanup**

```bash
docker compose down
```
