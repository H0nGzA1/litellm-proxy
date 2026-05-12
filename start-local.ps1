param(
    [string]$Port = "4000"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvActivate = Join-Path $ScriptDir ".venv\Scripts\activate.ps1"

if (-not (Test-Path $VenvActivate)) {
    Write-Host "Virtual environment not found. Run: uv venv && uv pip install litellm[proxy]" -ForegroundColor Red
    exit 1
}

Write-Host "Activating venv..." -ForegroundColor Cyan
. $VenvActivate

Write-Host "Starting LiteLLM proxy on port $Port..." -ForegroundColor Cyan
Write-Host "Config: $ScriptDir\litellm_config.yaml" -ForegroundColor DarkGray
Write-Host "Proxy: http://localhost:$Port" -ForegroundColor Green
Write-Host "Master key: sk-proxy-master-key" -ForegroundColor Yellow

litellm --config "$ScriptDir\litellm_config.yaml" --port $Port
