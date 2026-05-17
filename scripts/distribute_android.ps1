param(
    [string]$ReleaseNotes = "Bug fixes and improvements"
)

$ErrorActionPreference = "Stop"

Write-Host "Starting Android build and distribution..." -ForegroundColor Cyan

# Define variables
$AppId = "1:528515022630:android:0c4870812e3cc0dca4cbe7"
$ApkPath = "build/app/outputs/flutter-apk/app-release.apk"

# Navigate to mobile_app
Push-Location "mobile_app"

try {
    Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
    flutter clean

    Write-Host "Fetching dependencies..." -ForegroundColor Yellow
    flutter pub get

    Write-Host "Building release APK..." -ForegroundColor Yellow
    flutter build apk --release

    Write-Host "Uploading to Firebase App Distribution..." -ForegroundColor Yellow
    firebase appdistribution:distribute $ApkPath `
        --app $AppId `
        --release-notes "$ReleaseNotes" `
        --groups "dev,testers"
    
    Write-Host "Successfully uploaded!" -ForegroundColor Green
}
finally {
    Pop-Location
}
