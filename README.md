# QR CODE FOUNDRY

**EN:** Forge branded QR code pages for iOS.  
**FR:** Forgez des pages QR personnalisées sur iOS.

| | |
|---|---|
| **Bundle ID** | `com.magicsplitter.qrfoundry` |
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

## Notes

- Screen **recording** is blocked with an overlay; QR previews are shielded from casual screenshots.
- Legitimate **export / share** still works via `ImageRenderer`.
- Subscriptions for saving QR pages are planned later.

## License

Proprietary — all rights reserved.
