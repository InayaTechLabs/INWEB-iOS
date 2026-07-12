# 📱 iPhone-এ INWEB Install করার Guide (Mac ছাড়া, PC ছাড়া!)

আপনার হাতে **শুধু iPhone আছে, Mac বা Windows PC নেই?** সমস্যা নেই! এই guide-এ দেখানো হয়েছে কীভাবে **শুধু iPhone দিয়েই** INWEB iOS app install করবেন।

---

## 🎯 কী দরকার

| জিনিস | কেন |
|---|---|
| 📱 **iPhone (iOS 16+)** | INWEB চালাতে |
| 🌐 **Wi-Fi / Mobile data** | Download + signing |
| 📧 **Free Apple ID** | Signing এর জন্য |
| 🔗 **Safari browser** | Signing service open করতে |
| 🌍 **এই GitHub Release page-এর URL** | IPA download link |

---

## 📥 Step 1: IPA URL কপি করুন

1. iPhone-এ **Safari** খুলুন
2. যান: **https://github.com/InayaTechLabs/INWEB-iOS/releases/latest**
3. Assets section-এ scroll করুন
4. **`INWEB-iOS-v1.0.0-unsigned.ipa`** এর উপরে **long-press** (ধরে রাখুন) করুন
5. Menu থেকে **"Copy Link"** ট্যাপ করুন

**Save this URL** — এটাই আপনার IPA URL।

---

## 🌐 Step 2: Online Signer বেছে নিন

তিনটা সেবা আছে — যেকোনো একটা try করুন:

### 🥇 Option A: Signulous (recommended)

**URL:** https://signulous.com

| Pricing | Signing type | Reliability |
|---|---|:---:|
| Free plan | Personal signing (revoked frequently) | ⭐⭐ |
| $19.99/yr Plus | Enterprise cert (stable) | ⭐⭐⭐⭐ |
| $39.99/yr Ultra | Multiple certs + push notifications | ⭐⭐⭐⭐⭐ |

**How to use (Safari):**
1. https://signulous.com → **Sign In** (create account with Apple ID)
2. Dashboard → **"Add App via URL"**
3. IPA URL paste করুন (Step 1 থেকে)
4. **"Sign & Install"** ট্যাপ করুন
5. iPhone Safari popup আসবে → **"Install"**
6. Settings → General → VPN & Device Management → **Trust** the certificate
7. Home screen থেকে INWEB launch করুন 🎉

---

### 🥈 Option B: ESign (Chinese, free)

**URL:** https://esign.yyyue.xyz

**How to use:**
1. Safari-তে URL open করুন
2. Language English-এ change করুন (top-right)
3. **Cloud → Import URL**
4. IPA URL paste করুন
5. **Sign with default cert** ট্যাপ করুন
6. **Install** → Safari popup accept
7. Trust the certificate in Settings

⚠️ Chinese servers — data privacy about Apple ID concerns থাকতে পারে।

---

### 🥉 Option C: Scarlet (free, community)

**URL:** https://usescarlet.com

**How to use:**
1. Safari-তে https://usescarlet.com যান
2. **"Get Scarlet"** ট্যাপ করুন
3. Configuration profile install হবে → Settings → Profile Downloaded → Install
4. Home screen-এ Scarlet app launch হবে
5. Scarlet → **Downloads → Import** → paste IPA URL
6. **Sign** → **Install** → Trust in Settings

⚠️ Community-signed cert — 7-30 days-এ revoke হয় সাধারণত।

---

## 🔐 Step 3: Trust the Certificate

Install করার পর app launch করতে গেলে **"Untrusted Enterprise Developer"** error আসবে। এটা fix করতে:

1. iPhone → **Settings**
2. **General → VPN & Device Management**
3. আপনার signing service এর certificate দেখবেন (e.g. "Signulous", "Apple Development: yourname@email")
4. Certificate ট্যাপ করুন
5. **"Trust [certificate name]"** ট্যাপ করুন
6. Confirmation-এ **"Trust"** ট্যাপ করুন
7. এখন home screen থেকে INWEB launch করুন ✅

---

## ⚠️ Signing এর সীমাবদ্ধতা

| Signing Type | Expiration | Multiple apps | Cost |
|---|:---:|:---:|:---:|
| 🆓 **Free personal (Apple ID)** | **7 days** | Max 3 | Free |
| 💵 **Signulous Plus** | 1 year | Unlimited | $19.99/yr |
| 🏢 **Enterprise certs (from ESign/Scarlet)** | Until revoked | Unlimited | Free |
| 💎 **Apple Developer Program** | 1 year | Unlimited | $99/yr |

### 📅 Free personal Apple ID এর case-এ:
- **প্রতি ৭ দিনে app expire হবে**
- আপনাকে আবার signing service-এ গিয়ে re-sign করতে হবে
- অথবা upgrade করুন paid signing plan-এ

---

## 🔧 Troubleshooting

### ❌ "App could not be verified"
- Settings → General → VPN & Device Management → Trust the cert

### ❌ "Unable to install"
- Signer's certificate revoke হয়ে গেছে → নতুন signer try করুন

### ❌ "This app cannot be installed because its integrity could not be verified"
- IPA corrupted or partial download
- URL check করুন, আবার try করুন

### ❌ INWEB app crash immediately
- Certificate expired → re-sign it
- iOS version too old? — iOS 16+ লাগবে

### 🔵 INWEB চলছে কিন্তু connect করতে পারছে না
- Android app চালু আছে? START button চাপা?
- iPhone + Android একই Wi-Fi-এ?
- Firewall block করছে না তো?

---

## 🇧🇩 বাংলায় সংক্ষেপে

আপনার iPhone-এ INWEB install করতে ৩টা step:

1. **Safari-তে GitHub Release page** থেকে IPA URL copy করুন
2. **Signulous / ESign / Scarlet** এর যেকোনো একটায় URL paste করে sign করুন
3. **Settings-এ certificate trust** করে app চালু করুন

সবচেয়ে সহজ path: **Signulous → Free plan** (৭ দিন per sign) বা **$19.99/yr Plus plan** (এক বছর stable)।

---

## 🆘 কোনো সমস্যা?

- 📖 Full building guide: [`docs/BUILDING.md`](BUILDING.md)
- 💬 Issues: https://github.com/InayaTechLabs/INWEB-iOS/issues
- 📧 Email: support@inweb.app

---

Made with 💚 in Bangladesh · **INWEB iOS**
