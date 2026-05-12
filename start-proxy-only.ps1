Write-Host "Starting LiteLLM proxy..." -ForegroundColor Cyan
docker compose up -d
Start-Sleep -Seconds 3
Write-Host "Proxy running at http://localhost:4000" -ForegroundColor Green
Write-Host "Master key: sk-proxy-master-key" -ForegroundColor Yellow
