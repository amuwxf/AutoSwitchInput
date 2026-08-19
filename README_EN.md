# AutoSwitchInput

> A tiny menu-bar utility that auto-switches your macOS input source per app.

---

## Introduction

AutoSwitchInput is a native macOS menu-bar app. As you switch between foreground apps, it automatically selects the input source defined by your rules — for example, terminal apps always switch to English (ABC), while chat apps like WeChat switch to Pinyin. No more toggling input methods by hand.

---

## Features

- **Per-app auto switch** — Watches the active app (80ms debounce) and applies the matching rule.
- **Rule-based** — Each rule maps a bundle ID to an input source, with a live dropdown picker.
- **Sensible defaults** — Seeded on first launch: Terminal/iTerm2/VS Code/Xcode/Warp → ABC; WeChat → Pinyin.
- **Menu-bar background agent** — No Dock icon; a persistent menu-bar item only. Launches and stays resident in the background; click the icon to open the window anytime.
- **Liquid Glass UI** — Native Liquid Glass on macOS 26 (Tahoe); gracefully falls back to a thin-material look on older macOS.
- **Deep-gray theme** — A consistent deep-gray accent and app icon, replacing the default blue.
- **Launch at login** — Toggle "launch at login" in General settings.
- **⌘W to close** — Closing the window keeps the app resident in the menu bar; click the menu-bar icon to reopen.

---

## Requirements

- macOS 14.0 or later
- Apple Silicon (arm64)
- Input switching requires system authorization; you may need to grant **Input Monitoring / Accessibility** permission in System Settings on first use.
- Building from source requires the **Xcode Command Line Tools**.

---

## Installation

**Option A: Build from source (recommended)**

```bash
cd AutoSwitchInput
bash build.sh
open /Applications/AutoSwitchInput.app
```

`build.sh` compiles an arm64 binary, packages it into a `.app`, ad-hoc signs it, and auto-deploys to `/Applications`.

**Option B: Run the workspace build**

```bash
cd AutoSwitchInput
bash build.sh
open AutoSwitchInput.app
```

> If macOS blocks the unsigned app: System Settings › Privacy & Security › Allow Anyway.

---

## Usage

1. Launches quietly in the background (persistent menu-bar icon); click the icon to open the window. After closing, the app stays resident.
2. **General**
   - Enable auto switch — master toggle.
   - Default input source — fallback when no rule matches.
   - Launch at login.
3. **App rules**
   - One row per app; pick the target input source from the dropdown; click the trash to remove.
   - Click *Add Rule* to pick from currently running apps.
4. Switch apps and watch the input source follow your rules.

---

## Preview

> The image below is a mockup matching the actual UI; real captures live in [docs/screenshots](./docs/screenshots).

![AutoSwitchInput main window](./docs/screenshots/main-window.png)

---

## Project Structure

```
AutoSwitchInput/
├── Sources/
│   ├── main.swift              # AppKit entry; drives AppDelegate (replaces @main)
│   ├── AppDelegate.swift       # Status bar, window, ⌘W, Dock reopen logic
│   ├── AppMonitor.swift        # Watches foreground app switches
│   ├── InputMethodManager.swift # Carbon TIS API wrapper
│   ├── RuleStore.swift         # Rule persistence (UserDefaults) + launch-at-login
│   ├── SettingsView.swift      # SwiftUI main UI (Liquid Glass)
│   └── Design.swift            # Design tokens and LiquidGlass modifier
├── Resources/
│   ├── Info.plist
│   ├── AppIcon.icns            # Deep-gray keyboard app icon
│   └── icon_src/gen_dock_icon.swift  # Icon generation script
├── build.sh                    # Build + package + deploy script
├── LICENSE                     # GPLv3
├── README.md                   # Chinese documentation
└── README_EN.md                # English documentation
```

---

## Tech Stack

Swift 6 · SwiftUI · AppKit · Carbon TIS API · direct `swiftc` compilation (no Xcode project) · ad-hoc signing · `SMAppService.mainApp` login item.

---

## License

Licensed under the **GNU General Public License v3.0 (GPLv3)**. See [LICENSE](./LICENSE).
