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
