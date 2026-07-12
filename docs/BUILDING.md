# 🏗 INWEB iOS — Build & Distribute Guide

Complete guide to build, sign, and distribute the INWEB iOS app.

📖 **Table of contents:**
1. [Overview: 4 build paths](#-overview-4-build-paths)
2. [Path A · Local Mac build (personal use)](#-path-a--local-mac-build-personal-use)
3. [Path B · Xcode Cloud (Apple's free CI)](#-path-b--xcode-cloud-apples-free-ci) ⭐ recommended
4. [Path C · Fastlane + TestFlight](#-path-c--fastlane--testflight-power-users)
5. [Path D · GitHub Actions macOS runners](#-path-d--github-actions-macos-runners-paid)
6. [App Store submission checklist](#-app-store-submission-checklist)
7. [বাংলায় সংক্ষেপে](#-বাংলায়-সংক্ষেপে)

---

## 🔍 Overview: 4 build paths

Unlike Android (where any Linux machine can build APKs), **iOS apps can only be compiled on macOS** with Xcode. This means you have 4 practical options:

| Path | Cost | Complexity | Distribution | Best for |
|:---:|:---:|:---:|:---:|---|
| **A** 🏠 Local Mac build | Free* | Low | Sideload only | Testing on own device |
| **B** ☁️ Xcode Cloud | Free tier (25 hr/mo) | Medium | TestFlight + App Store | ⭐ Most users |
| **C** 🚀 Fastlane + TestFlight | Free | High | TestFlight + App Store | CI/CD purists |
| **D** 🤖 GitHub Actions macOS | ~$0.08/min | Medium | Any | Existing GH workflow |

*Free if you have a Mac; $99/year Apple Developer Program required for TestFlight/App Store.

---

## 🏠 Path A · Local Mac build (personal use)

Simplest option for testing on your own iPhone. **No Apple Developer account needed** for 7-day self-signed builds.

### Prerequisites
- Mac with **macOS 13+**
- **Xcode 15+** (free from Mac App Store, ~10 GB)
- iPhone with **iOS 16+**
- Lightning/USB-C cable
- Free Apple ID

### Step 1: Download source

```bash
# Option 1: Clone the repo
git clone https://github.com/InayaTechLabs/INWEB-iOS.git
cd INWEB-iOS

# Option 2: Download source archive from Releases
# https://github.com/InayaTechLabs/INWEB-iOS/releases
```

### Step 2: Create Xcode project

The repo doesn't include an `.xcodeproj` (they're huge and git-noisy). Create one:

1. **Open Xcode → File → New → Project**
2. **iOS → App** → Next
3. Fill in:
   - Product Name: `INWEB`
   - Team: your Apple ID
   - Organization Identifier: `com.inweb`
   - Bundle Identifier: `com.inweb.ios` (auto-filled)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - ❌ Uncheck "Include Tests"
4. Save location: anywhere (creates `INWEB/` folder inside)
5. **Delete** the auto-generated `ContentView.swift`
6. **Drag** the `INWEB/` folder from this repo into your Xcode project sidebar
   - ✅ "Copy items if needed" checked
   - ✅ "Create groups" selected
   - ✅ Add to target: `INWEB`

### Step 3: Configure project

**Target INWEB → General:**
- **Deployment Info → iOS 16.0**
- **Display Name:** INWEB
- **Version:** 1.0.0
- **Build:** 1

**Target INWEB → Info:**
Add these keys (or merge our `Resources/Info.plist`):
```xml
<key>NSAllowsLocalNetworking</key><true/>
<key>NSLocalNetworkUsageDescription</key>
<string>INWEB connects to your Android device on the local network.</string>
```

**Target INWEB → Signing & Capabilities:**
- ✅ Automatically manage signing
- Team: your Apple ID
- Signing Certificate: Apple Development (auto)

### Step 4: Build & Run

1. Connect iPhone via cable
2. Select your iPhone from top toolbar device dropdown
3. Press **⌘R** (or click ▶ Run)
4. First time: iPhone will show "Untrusted Developer" — go to
   **Settings → General → VPN & Device Management → your Apple ID → Trust**
5. Launch INWEB from home screen 🎉

### ⚠️ Limitations of free Apple ID
- App **expires after 7 days** — you must rebuild
- Only **3 apps** can be signed simultaneously
- No TestFlight, no App Store, no push notifications

Upgrade to **Apple Developer Program ($99/year)** for unlimited builds + TestFlight + App Store.

---

## ☁️ Path B · Xcode Cloud (Apple's free CI) ⭐ recommended

Apple's own CI service. **Free tier: 25 build hours/month**, TestFlight integration built-in.

### Prerequisites
- Mac + Xcode 15+
- **Apple Developer Program membership ($99/year)**
- Xcode project committed to Git (works with GitHub, GitLab, Bitbucket)

### Step 1: Create the Xcode project (once)

Follow **Path A · Step 2 & 3** above. Then:

```bash
cd INWEB-iOS
git add INWEB.xcodeproj
git commit -m "add: Xcode project"
git push
```

### Step 2: Enable Xcode Cloud

1. Open project in Xcode
2. **Report Navigator (⌘9) → Cloud tab → Get Started**
3. Sign in with your Apple Developer account
4. **Grant Xcode Cloud access to your GitHub repo**
5. Create a **Workflow**:
   - Name: `Nightly Build`
   - Start Conditions: **On Push to `main`** and **On tag matching `v*`**
   - Environment: **Latest Release** (iOS 17+)
   - Actions:
     - ✅ Build (all destinations)
     - ✅ Test (if you have tests)
     - ✅ Archive → Post-Actions: **TestFlight (Internal Testing)**

### Step 3: Trigger a build

```bash
git tag v1.0.1
git push origin v1.0.1
```

Xcode Cloud automatically:
1. Clones repo on a Mac VM
2. Builds `.ipa` with your credentials
3. Uploads to App Store Connect
4. Notifies internal testers via TestFlight

Testers install via **TestFlight app** on their iPhone — no jailbreak, no cables, no fuss!

### Step 4: Public TestFlight (external testers)

1. **App Store Connect → TestFlight → External Testing → Add Group**
2. Add tester emails (or public link — up to 10,000 testers)
3. Submit build for **Beta App Review** (~24-48 hr)
4. Approved builds auto-notify all external testers

### Step 5: App Store release

Once TestFlight-tested:
1. **App Store Connect → App Store tab → Prepare for Submission**
2. Fill store metadata (see `play_store/listing.md` in Android repo for content ideas)
3. Upload screenshots (5.5" + 6.5" + 6.7" iPhone screens required)
4. Set pricing, availability, category
5. **Submit for Review** → 1-3 days average

---

## 🚀 Path C · Fastlane + TestFlight (power users)

For those who prefer full CLI automation.

### Install Fastlane

```bash
brew install fastlane
# or: sudo gem install fastlane
```

### Initialize

```bash
cd INWEB-iOS/INWEB.xcodeproj
fastlane init
# Choose "Automate beta distribution to TestFlight"
```

### Sample `fastlane/Fastfile`

```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new beta to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "INWEB.xcodeproj")
    build_app(
      scheme: "INWEB",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end
```

### Deploy

```bash
fastlane beta
```

Handles everything: build → sign → upload → TestFlight notify.

---

## 🤖 Path D · GitHub Actions macOS runners (paid)

If you insist on GitHub Actions (like INWEB-Android), you can use macOS runners.

⚠️ **Cost:** GitHub charges ~$0.08/minute for macOS runners.
A typical iOS build takes **10-15 minutes** = **$0.80-1.20 per build**.

### Enable billing

Repo Settings → Billing → set spending limit.

### Sample workflow (`.github/workflows/ios-xcode-build.yml`)

```yaml
name: 🏗 Xcode Build (macOS)
on:
  push:
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: macos-14
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - name: 🍎 Select Xcode 15
        run: sudo xcode-select -s /Applications/Xcode_15.4.app

      - name: 🔐 Import signing cert
        env:
          CERT_P12_BASE64: ${{ secrets.CERT_P12_BASE64 }}
          CERT_PASSWORD:   ${{ secrets.CERT_PASSWORD }}
        run: |
          echo "$CERT_P12_BASE64" | base64 -d > cert.p12
          security create-keychain -p "" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "" build.keychain
          security import cert.p12 -k build.keychain -P "$CERT_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain

      - name: 🏗 Build IPA
        run: |
          xcodebuild -project INWEB.xcodeproj \
            -scheme INWEB \
            -configuration Release \
            -destination generic/platform=iOS \
            -archivePath INWEB.xcarchive \
            archive

          xcodebuild -exportArchive \
            -archivePath INWEB.xcarchive \
            -exportPath . \
            -exportOptionsPlist ExportOptions.plist

      - name: 📤 Upload IPA artifact
        uses: actions/upload-artifact@v4
        with:
          name: INWEB-${{ github.ref_name }}.ipa
          path: "*.ipa"
```

### Required secrets
- `CERT_P12_BASE64` — Base64-encoded distribution certificate `.p12`
- `CERT_PASSWORD` — Password to decrypt the `.p12`
- `APPLE_ID` + `APP_PASSWORD` — For TestFlight upload

---

## 📋 App Store submission checklist

Before submitting to App Store review:

| Item | Where |
|---|---|
| ✅ App icon (1024×1024 + all size variants) | Xcode → Assets.xcassets |
| ✅ Launch screen | LaunchScreen.storyboard |
| ✅ Screenshots — iPhone 6.7" (1290×2796) | App Store Connect |
| ✅ Screenshots — iPhone 6.5" (1284×2778) | App Store Connect |
| ✅ Screenshots — iPhone 5.5" (1242×2208) | App Store Connect |
| ✅ App preview video (optional but recommended) | App Store Connect |
| ✅ App description (max 4000 chars) | App Store Connect |
| ✅ Keywords (100 chars, comma-separated) | App Store Connect |
| ✅ Category (Primary + Secondary) | App Store Connect |
| ✅ Age rating questionnaire | App Store Connect |
| ✅ **Privacy policy URL** (required for network apps!) | App Store Connect |
| ✅ Support URL | App Store Connect |
| ✅ Marketing URL (optional) | App Store Connect |
| ✅ Contact info | App Store Connect |
| ✅ Demo credentials (if login required) | For review team |
| ✅ Export Compliance (`ITSAppUsesNonExemptEncryption=false`) | Info.plist |

### Ideal INWEB iOS listing

```
Name:     INWEB — Server Remote
Subtitle: Control your Android web server
Category: Developer Tools (Primary), Utilities (Secondary)
Keywords: web server, nginx, php, mariadb, developer, localhost, remote, docker, kubernetes, ssh
```

---

## 🇧🇩 বাংলায় সংক্ষেপে

### iOS build করার জন্য কী লাগবে?

| জিনিস | কেন |
|---|---|
| 🖥 **Mac + Xcode 15+** | iOS build শুধু Mac-এ হয় |
| 📱 **iPhone (iOS 16+)** | Test করতে |
| 💰 **Apple Developer Program ($99/বছর)** | TestFlight + App Store এর জন্য |

### সহজতম path

1. **Mac-এ Xcode install** করুন (App Store থেকে free)
2. **Repo clone** করুন
3. **নতুন Xcode project** বানান, `INWEB/` folder drag করে দিন
4. **⌘R** press করে run করুন

**Apple Developer একাউন্ট না থাকলে:** ৭ দিন পর app expire হবে, তখন আবার build করতে হবে।

**App Store publish করতে চাইলে:** Apple Developer Program membership ($99/year) কিনতে হবে, তারপর Xcode Cloud বা Fastlane দিয়ে TestFlight → App Store publish।

---

## 🔗 Resources

- Apple Developer Program: https://developer.apple.com/programs/
- Xcode Cloud docs: https://developer.apple.com/xcode-cloud/
- Fastlane docs: https://docs.fastlane.tools/
- TestFlight: https://developer.apple.com/testflight/
- App Store Connect: https://appstoreconnect.apple.com/

---

Made with 💚 in Bangladesh · **INWEB iOS**
