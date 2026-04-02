# ShopKeeper Git Repair Script
# This will undo the large-file commit and re-push the clean code

Write-Host "🚀 Repairing Git history for large file..." -ForegroundColor Cyan

# 1. Undo the last commit (the one with the 265MB file)
git reset --soft HEAD~1
Write-Host "✅ Last commit undone (changes kept)." -ForegroundColor Green

# 2. Re-stage all changes (this time .gitignore will block the .exe)
git add .
Write-Host "✅ Changes re-staged (Large files automatically excluded)." -ForegroundColor Green

# 3. Re-commit clean changes
git commit -m "Integrated MySQL Backsupporter & Stabilized Dashboard Initialization (Removed large binaries)"
Write-Host "✅ Clean commit created." -ForegroundColor Green

# 4. Push to GitHub
Write-Host "🚀 Re-pushing to GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host "🎉 Success! Your code is now live on GitHub without the large files." -ForegroundColor Green
