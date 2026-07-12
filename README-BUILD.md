# Building INWEB for iOS

The Swift source files are complete and production-ready. To turn them
into a runnable Xcode project:

## Option A — Fresh Xcode project (recommended)

1. Open **Xcode 15+** → **File → New → Project…**
2. Pick **iOS → App**
3. Fill in:
   - Product Name: `INWEB`
   - Team: your Apple developer team
   - Organization Identifier: `app.inweb.ios`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
4. Choose a location (e.g. `~/Code`) — creates `INWEB/` folder
5. **Delete** the auto-generated `INWEBApp.swift` and `ContentView.swift`
6. Drag the entire `INWEB/` folder from this repository into your Xcode
   project navigator, using **"Create groups"** (not folder references)
7. Replace the auto-generated `Info.plist` with `Resources/Info.plist`
   from this repo
8. Set the deployment target to **iOS 16.0**
9. Hit **⌘R** — the app builds and runs

## Option B — Swift Package Manager (for testing logic)

The API client + models compile as a pure Swift package. Create a
`Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "INWEBCore",
    platforms: [.iOS(.v16)],
    products: [.library(name: "INWEBCore", targets: ["INWEBCore"])],
    targets: [.target(name: "INWEBCore", path: "INWEB/Core")]
)
```

Then `swift build` — useful for unit-testing the API client without Xcode.

## No third-party dependencies

INWEB for iOS uses only Apple frameworks:
- **SwiftUI** — all UI
- **Foundation** — URLSession, JSONDecoder
- **Security** — Keychain
- **Combine** — `@ObservableObject` reactivity

No SPM packages, no CocoaPods, no Carthage. This keeps the app well
under 10 MB and passes App Store review the fastest.

## Signing + Provisioning

For personal use on your own iPhone:
1. Xcode → target settings → **Signing & Capabilities**
2. Enable **Automatically manage signing**
3. Pick your Apple ID team
4. Free provisioning gives you 7-day builds — good enough for personal use

For distribution:
1. Enroll in the [Apple Developer Program](https://developer.apple.com/)
   (US$99/year)
2. Upload via **Xcode → Product → Archive → Distribute App**
