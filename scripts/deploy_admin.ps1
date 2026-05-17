$ErrorActionPreference = "Stop"

Write-Host "Starting Admin Panel deployment..." -ForegroundColor Cyan

# Navigate to admin_panel
Push-Location "admin_panel"

try {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install

    Write-Host "Building project..." -ForegroundColor Yellow
    npm run build

    Write-Host "Deploying to Firebase Hosting..." -ForegroundColor Yellow
    firebase deploy --only hosting
    
    Write-Host "Deployment complete!" -ForegroundColor Green
}
finally {
    Pop-Location
}
