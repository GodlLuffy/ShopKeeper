# ShopKeeper Update Script
# This will push all our MySQL and Stability repairs to GitHub

Write-Host "🚀 Preparing to push ShopKeeper updates..." -ForegroundColor Cyan

# 1. Stage all changes
git add .
Write-Host "✅ Changes staged." -ForegroundColor Green

# 2. Commit changes
git commit -m "Integrated MySQL Backsupporter & Stabilized Dashboard Initialization"
Write-Host "✅ Changes committed." -ForegroundColor Green

# 3. Push to GitHub
Write-Host "🚀 Uploading to GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host "🎉 Push complete! Your code is now safe on GitHub." -ForegroundColor Green
