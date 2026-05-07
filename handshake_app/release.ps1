# ============================================
# 🤝 HandShake App - Automatikus Release Script
# ============================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,

    [string]$ReleaseNotes = "🎉 New version!"
)

Write-Host "🚀 Starting release process for v$Version..." -ForegroundColor Cyan
Write-Host ""

# 1. Build APK
Write-Host "📦 Building APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"

if (-not (Test-Path $apkPath)) {
    Write-Host "❌ APK not found at $apkPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ APK built successfully!" -ForegroundColor Green
Write-Host ""

# 2. GitHub CLI ellenőrzés
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghInstalled) {
    Write-Host "⚠️ GitHub CLI not installed!" -ForegroundColor Yellow
    Write-Host "Install it from: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual upload needed:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/nhGeri/HandShake-releases/releases/new" -ForegroundColor White
    Write-Host "2. Tag: v$Version" -ForegroundColor White
    Write-Host "3. Upload: $apkPath" -ForegroundColor White
    exit 0
}

# 3. GitHub Release létrehozás
Write-Host "📤 Creating GitHub Release v$Version..." -ForegroundColor Yellow

gh release create "v$Version" $apkPath `
    --repo "nhGeri/HandShake-releases" `
    --title "HandShake v$Version" `
    --notes "$ReleaseNotes"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 Release v$Version published successfully!" -ForegroundColor Green
    Write-Host "🔗 https://github.com/nhGeri/HandShake-releases/releases/tag/v$Version" -ForegroundColor Cyan
} else {
    Write-Host "❌ Release creation failed!" -ForegroundColor Red
    exit 1
}
