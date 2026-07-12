# 🍎 INWEB for iOS

[![iOS CI](https://github.com/InayaTechLabs/INWEB-iOS/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/InayaTechLabs/INWEB-iOS/actions/workflows/ios-ci.yml)
![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-000000?style=flat-square&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-14B8A6?style=flat-square)

Native SwiftUI companion app for [**INWEB-Android**](https://github.com/InayaTechLabs/INWEB-Android).
Lets you monitor and control your Android-hosted local web server from
an iPhone or iPad on the same Wi-Fi.

## What it does

- 📊 **Live dashboard** — CPU / RAM / storage / network stats, 3-second polling
- 🌐 **Virtual host manager** — add/edit/delete sites remotely
- 🏠 **Custom DNS mappings** — hostname → IP editor
- 📜 **Log tail** — real-time access / error / php-fpm.error logs
- ⚙️ **Settings sync** — every toggle instantly applied on Android
- 🕌 **Prayer times strip** — pulls from the Android's built-in astronomical API
- 🔐 **Keychain-backed auth** — bearer token stored securely

## What it does NOT do

iOS forbids apps from running long-running HTTP servers or listening on
sockets in the background. That's why INWEB for iOS is a **remote
control** rather than a standalone server. If you need to *host* a site
on iOS, use Apple's Safari Web Inspector against a real macOS server —
INWEB isn't a workaround for that.

## Getting started

1. On your Android device, install [INWEB](../LocalServerApp) and enable
   **Settings → Web Dashboard**. Copy the URL and token shown.
2. On your iPhone, open INWEB for iOS.
3. Paste the URL (e.g. `http://192.168.1.42:8181`) and the bearer token.
4. Tap **Connect**. Done.

## Requirements

- iOS **16.0** or newer (iPhone or iPad)
- Xcode **15+** to build
- Both devices on the **same Wi-Fi network**

## Project layout

```
INWEB/
├── App/
│   ├── INWEBApp.swift          — @main entry, root router
│   ├── INWEBTheme.swift        — brand palette (mirrors Android colors.xml)
│   └── DashboardTabs.swift     — 5-tab shell
├── Core/
│   ├── API/
│   │   └── INWEBApi.swift      — REST client (mirrors ApiRouter.kt)
│   ├── Models/
│   │   └── APIModels.swift     — Codable structs
│   └── Storage/
│       ├── Session.swift       — @ObservableObject holding host + token
│       └── Keychain.swift      — secure token storage
└── Features/
    ├── Login/LoginView.swift
    ├── Dashboard/              — Home tab
    │   ├── DashboardView.swift
    │   ├── DashboardViewModel.swift
    │   ├── ServerStatusCard.swift
    │   └── StatCard.swift
    ├── Sites/                  — Virtual hosts
    │   ├── SitesView.swift
    │   └── VHostEditor.swift
    ├── Hosts/                  — DNS mappings
    │   └── HostsView.swift
    ├── Logs/LogsView.swift
    ├── Settings/SettingsView.swift
    └── Prayer/PrayerStripView.swift
```

## Design language

The iOS app is a **faithful port** of the Android design:

| Android          | iOS equivalent           |
|------------------|--------------------------|
| Material CardView| `INWEBCard` custom view  |
| Bottom Nav       | SwiftUI `TabView`        |
| SectionLabel     | `SectionLabel` view      |
| ProgressBar      | Custom capsule in `StatCard` |
| Toolbar          | `NavigationStack` toolbar |

Same emerald + teal palette, same section labels, same monospace fonts
for technical data. Users switching between platforms feel at home.

## To build

Open `INWEB.xcodeproj` in Xcode 15+, select an iOS device or simulator,
and hit ⌘R. The project has **zero external dependencies** — no Swift
Package Manager or CocoaPods needed.

## Roadmap

- [ ] File editor (send file writes over REST)
- [ ] Widget: server status on home screen
- [ ] Live Activity: server up-time on Dynamic Island
- [ ] Watch companion app
- [ ] SharePlay: view logs together during pair debugging
