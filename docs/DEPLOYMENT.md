# TARRIFIC CHAT - Deployment Guide

## Option 1: Build APK & Host on Your Website (FREE)

### Step 1: Build APK (No Android Studio needed)
```bash
# Install Flutter first: https://docs.flutter.dev/get-started/install

# Clone your repo
git clone https://github.com/YOURNAME/tarrific-chat.git
cd tarrific-chat

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Your APK is at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Step 2: Host APK on Free Website

#### Option A: GitHub Pages (FREE)
1. Create repo `tarrific-chat` on GitHub
2. Push your code
3. Go to Settings → Pages → Source: GitHub Actions
4. The workflow file `.github/workflows/build.yml` already handles this
5. Your site: `https://YOURNAME.github.io/tarrific-chat`

#### Option B: Vercel (FREE + Custom Domain)
1. Sign up at [vercel.com](https://vercel.com) with GitHub
2. Import your repo
3. Build settings:
   - Framework: `Other`
   - Build Command: `flutter/bin/flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && flutter/bin/flutter doctor && flutter/bin/flutter config --enable-web`
4. Deploy!
5. Add custom domain in Vercel dashboard → Domains

#### Option C: Netlify (FREE + Custom Domain)
1. Sign up at [netlify.com](https://netlify.com)
2. Drag & drop the `build/web` folder
3. Or connect GitHub repo
4. Add custom domain in Site Settings → Domain Management

### Step 3: Custom Domain Setup

1. **Buy domain**: Namecheap, Cloudflare, or GoDaddy (~$10-15/year)
2. **DNS Settings** (for Vercel/Netlify):
   - Type: CNAME
   - Name: www
   - Value: cname.vercel-dns.com (or Netlify's value)

   OR for root domain:
   - Type: A
   - Name: @
   - Value: 76.76.21.21 (Vercel) or Netlify's IP

3. **SSL**: Automatic (Let's Encrypt) — free on Vercel/Netlify

### Step 4: Users Download APK from Your Site

Add this to your website:
```html
<a href="https://yourdomain.com/app-release.apk" download>
  Download TARRIFIC CHAT
</a>
```

Users tap → download APK → install (allow "Unknown Sources" in settings)

---

## Option 2: GitHub Actions (Auto-Build on Every Push)

The file `.github/workflows/build.yml` is already configured. Every time you push code:

1. GitHub builds APK automatically
2. Creates a release with downloadable APK
3. Deploys web version to GitHub Pages

**To use it:**
1. Push code to GitHub
2. Go to Actions tab → watch it build
3. Download APK from Releases tab

---

## Option 3: Backend Server Setup

### Tech Stack
- **Node.js + Express** — API server
- **Socket.IO** — Real-time messaging
- **MongoDB** — Database (free tier on MongoDB Atlas)
- **Redis** — Caching/sessions (free on Redis Cloud)
- **JWT** — Authentication

### Deploy Backend (FREE)
- **Render.com** — Free tier, auto-deploy from GitHub
- **Railway.app** — Free tier, easy deploy
- **Fly.io** — Free tier, global edge

### Environment Variables
```env
PORT=3000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
REDIS_URL=your_redis_url
FIREBASE_SERVER_KEY=your_fcm_key
```

---

## Cost Breakdown

| Item | Cost | Notes |
|------|------|-------|
| Domain | ~$12/year | Namecheap/Cloudflare |
| Website Hosting | FREE | Vercel/Netlify/GitHub Pages |
| APK Hosting | FREE | Same as website |
| Backend Server | FREE | Render/Railway free tier |
| Database | FREE | MongoDB Atlas 512MB |
| Push Notifications | FREE | Firebase Cloud Messaging |
| **Google Play Store** | **$25 one-time** | Only if you want Play Store |

**Total to launch: $12/year (domain only)**

---

## Quick Start Checklist

- [ ] Push code to GitHub
- [ ] Connect Vercel/Netlify to repo
- [ ] Buy domain and point DNS
- [ ] Build APK: `flutter build apk --release`
- [ ] Upload APK to website
- [ ] Share download link with users
- [ ] (Optional) Pay $25 for Play Store

---

## Troubleshooting

**"Flutter not found"**: Install Flutter SDK first
**"Build fails"**: Run `flutter doctor` and fix issues
**"Web blank"**: Check `build/web` folder exists after build
**"Custom domain not working"**: DNS propagation takes 24-48 hours
