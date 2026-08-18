# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project is licensed under GPLv3.

---

## [Unreleased]

### Added
- 中英文 README 与 CHANGELOG。 / Bilingual README and CHANGELOG.

---

## [2026-08-18] — Initial development (single-day iteration)

All features below were implemented and verified on 2026-08-18.

### Added
- **核心功能**：监听前台 App 切换（80ms 防抖），按规则自动切换输入法（Carbon TIS API）。 / Core per-app input-source switching with 80ms debounce via Carbon TIS.
- **默认规则**：Terminal / iTerm2 / VS Code / Xcode / Warp → ABC（英文）；微信 → 拼音（简体）。 / Default rules seeding common dev and chat apps.
- **规则管理 UI**：新增 / 删除规则，下拉即时切换目标输入法。 / Rule CRUD with a live dropdown picker.
- **双入口**：Dock 图标 + 菜单栏常驻图标（左键开主窗口、右键菜单）。 / Dock icon plus persistent status-bar item.
- **⌘W 关闭主窗口**：关闭后应用常驻菜单栏，点 Dock 可重开。 / ⌘W to close; reopen via Dock.
- **开机启动**：通用设置中通过 `SMAppService.mainApp` 注册登录项。 / Launch-at-login via `SMAppService.mainApp`.
- **液态玻璃界面（macOS 26）**：窗口 `NSVisualEffectView(.hudWindow)` + 卡片 `.glassEffect()` + 规则行玻璃，旧系统回退毛玻璃。 / Liquid Glass UI on macOS 26 with graceful fallback.
- **深灰主题**：统一深灰强调色与 Dock 图标（深灰方块 + 白色键盘符号）。 / Deep-gray theme and app icon.
- **隐藏系统滚动条**：让内容更轻地悬浮于玻璃窗口。 / Hidden scroll indicators for a lighter glass look.
- **GPLv3 许可**与 GitHub 开源仓库（`amuwxf/AutoSwitchInput`）。 / GPLv3 license and public GitHub repository.

### Changed
- 输入法切换由 SwiftUI `MenuBarExtra` 改为 **NSStatusItem + main.swift** 原生方案（`MenuBarExtra` 在 swiftc 直接编译下不渲染图标）。 / Switched from MenuBarExtra to NSStatusItem because MenuBarExtra does not render under direct swiftc compilation.
- 应用名由 `AutoSwitchInputMethod` 改为 **`AutoSwitchInput`**。 / Renamed the app bundle to AutoSwitchInput.
- 开关颜色由系统蓝改为深灰（`Toggle` 的 `.tint()` 控制开态，而非 `.accentColor()`）。 / Switch tint changed from system blue to deep gray via `.tint()`.
- 编译目标锁定 **arm64-apple-macosx14.0**，部署到 `/Applications`。 / Build target pinned to arm64 macOS 14.0 with auto-deploy to /Applications.

### Fixed
- 主窗口首次打开时尺寸塌缩为 0 宽。 / Window collapsed to zero-width on first open.
- 主窗口液态玻璃被渲染成透明椭圆（`.glassEffect()` 默认 capsule 形状）→ 改为 `.glassEffect(in: .rect(cornerRadius:))`。 / Glass rendered as an ellipse → locked to a rounded-rectangle shape.
- 关闭主窗口后再点 Dock 无法重开（旧窗口强引用残留）→ 关闭后重建干净窗口。 / Reopen-from-Dock failed after closing → rebuild a fresh window on reopen.

---

## Notes

- 本仓库无语义化版本号发布记录，变更以日期里程碑归档。 / No semantic-version releases yet; changes are archived by date milestone.
- 输入法切换依赖系统输入监控 / 辅助功能授权。 / Input switching requires Input Monitoring / Accessibility permission.
