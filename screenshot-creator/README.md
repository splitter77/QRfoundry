# Screenshot Creator

Local tool to crop App Store screenshots to the correct sizes.

## Open

```bash
open screenshot-creator/index.html
```

Or:

```bash
cd screenshot-creator && python3 -m http.server 8090
```

Then open `http://localhost:8090`.

## How to use

1. Drop your device screenshots (or click **Add images**)
2. Pick a target size (start with **iPhone 6.7"** — required by App Store)
3. Drag to reposition, use **Zoom** if needed
4. **Export this** or **Export all** → PNG downloads at exact pixels

## Folders

- `input/` — optional place to keep originals
- `output/` — optional place to archive exported PNGs (browser downloads to your Downloads folder by default)

## App Store sizes included

**Use these for your current ASC error:**

| Orientation | Size |
|-------------|------|
| Portrait | **1242 × 2688** |
| Portrait | **1284 × 2778** |
| Landscape | **2688 × 1242** |
| Landscape | **2778 × 1284** |

Also available: 1290×2796 (6.7"), 1320×2868 (6.9"), 2048×2732 (iPad 12.9").

Tip: pick **1242 × 2688** or **1284 × 2778**, export, then upload to App Store Connect.
