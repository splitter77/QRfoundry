# QR CODE FOUNDRY

**EN:** Forge branded QR code pages for iOS.  
**FR:** Forgez des pages QR personnalisées sur iOS.

| | |
|---|---|
| **Bundle ID** | `com.magicsplitter.qrcodefoundry` |
| **Platform** | iOS (iPhone & iPad) |
| **Languages** | English · Français |
| **UI** | SwiftUI |

---

## Features

- Create QR codes for **URL**, **Wi‑Fi**, **Text**, **Email**, **Phone**, **SMS**, **Contact**, and **Google Review**
- Customize each page: **logo**, titles, button, colors
- Live preview + **high-quality export** (share or save to Photos)
- Localized app name: **QR CODE FOUNDRY** (EN) / **QR CODE LA FABRIQUE** (FR)
- Launch screen & brand header with Foundry crest

## Requirements

- Xcode 16+ (or newer)
- iOS device or Simulator
- Apple Developer team for device installs / App Store

## Getting started

```bash
git clone https://github.com/splitter77/QRfoundry.git
cd QRfoundry
open QRmaster.xcodeproj
```

1. Select the **QRmaster** scheme  
2. Pick a simulator or your iPhone  
3. Run (▶)

## Project structure

```
QRmaster/
├── Views/           # Home, editor, export, splash, branding
├── Models/          # QR types, drafts, page styles, history
├── Services/        # QR generation, share, screen protection
├── Theme/           # Adaptive light/dark palette
├── Localization/    # L10n helpers
├── Localizable.xcstrings
├── InfoPlist.xcstrings
└── Assets.xcassets  # App icon & logo
```

## Landing page

Bilingual marketing site (EN / FR):

```bash
open landing/index.html
```

Or serve locally:

```bash
cd landing && python3 -m http.server 8080
```

Then open `http://localhost:8080`.

## Subscriptions (StoreKit)

Plans: **1 week**, **1 month**, **6 months**, **1 year**, **lifetime**.

Product IDs:

- `com.magicsplitter.qrcodefoundry.weekly`
- `com.magicsplitter.qrcodefoundry.monthly`
- `com.magicsplitter.qrcodefoundry.sixmonths`
- `com.magicsplitter.qrcodefoundry.yearly`
- `com.magicsplitter.qrcodefoundry.lifetime`

Local testing: open the scheme → **Run → Options → StoreKit Configuration** → select `Products.storekit`.

Pro unlocks: share export, save to Photos, and history. Creation & preview stay free.

## Notes

- Screen **recording** is blocked with an overlay; QR previews are shielded from casual screenshots.
- Legitimate **export / share** still works via `ImageRenderer` once Pro is active.
- Create matching IAPs in App Store Connect before release.

## License

Proprietary — all rights reserved.
