# TARRIFIC CHAT - Phone Deployment Guide

## Deploy from Your Phone (No Computer Needed)

### Step 1: Create GitHub Repo
1. Open Chrome/Safari on your phone
2. Go to github.com
3. Sign up / Log in
4. Tap + → New Repository
5. Name: `tarrific-chat`
6. Make it Public
7. Tap Create Repository

### Step 2: Upload Files
1. In your new repo, tap "uploading an existing file"
2. Select ALL files from this folder
3. Tap Commit changes

### Step 3: Auto-Build APK (GitHub Actions)
1. Go to Actions tab in your repo
2. You'll see "Build TARRIFIC CHAT" workflow
3. It runs automatically on upload
4. Wait 5-10 minutes
5. Go to Releases tab → Download APK

### Step 4: Deploy Website (Vercel)
1. Go to vercel.com on your phone
2. Sign up with GitHub
3. Tap "Add New Project"
4. Select your `tarrific-chat` repo
5. Framework: Other
6. Build Command: (leave empty, we handle it)
7. Tap Deploy
8. Done! Your site is live

### Step 5: Custom Domain
1. In Vercel dashboard, go to Domains
2. Buy domain or add existing
3. Follow DNS instructions
4. Wait 24-48 hours for propagation

---

## Files Included
- `lib/` - All Flutter source code (30+ screens)
- `backend/` - Node.js server with AI moderation
- `.github/workflows/` - Auto-build on every push
- `pubspec.yaml` - Flutter dependencies
- `vercel.json` - Web deployment config

---

## Total Cost
- GitHub: FREE
- Vercel: FREE
- Domain: ~$12/year (optional)
- Play Store: $25 (optional)

**You can launch for $0.**
