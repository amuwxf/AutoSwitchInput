# 更新日志

本项目所有值得注意的变更均记录于此。

本文件格式遵循 [Keep a Changelog](https://keepachangelog.com/)，项目以 GPLv3 开源。

---

## [未发布 / Unreleased]

### 新增
- 中文、英文分开的双版 README（`README.md` 中文、`README_EN.md` 英文）。

### 变更
- **转为纯菜单栏后台应用**：`Info.plist` 增加 `LSUIElement=true`，移除 Dock 图标，仅保留顶部菜单栏图标；启动与关闭窗口都安静留在后台（不再自动弹窗）。

---

## [2026-08-18] — 初始开发（单日迭代）

以下特性均于 2026-08-18 实现并验证。

### 新增
- **核心功能**：监听前台 App 切换（80ms 防抖），按规则自动切换输入法（Carbon TIS API）。
- **默认规则**：Terminal / iTerm2 / VS Code / Xcode / Warp → ABC（英文）；微信 → 拼音（简体）。
- **规则管理 UI**：新增 / 删除规则，下拉即时切换目标输入法。
- **双入口**：Dock 图标 + 菜单栏常驻图标（左键开主窗口、右键菜单）。
- **⌘W 关闭主窗口**：关闭后应用常驻菜单栏，点 Dock 可重开。
- **开机启动**：通用设置中通过 `SMAppService.mainApp` 注册登录项。
- **液态玻璃界面（macOS 26）**：窗口 `NSVisualEffectView(.hudWindow)` + 卡片 `.glassEffect()` + 规则行玻璃，旧系统回退毛玻璃。
- **深灰主题**：统一深灰强调色与 Dock 图标（深灰方块 + 白色键盘符号）。
- **隐藏系统滚动条**：让内容更轻地悬浮于玻璃窗口。
- **GPLv3 许可**与 GitHub 开源仓库（`amuwxf/AutoSwitchInput`）。

### 变更
- 输入法切换由 SwiftUI `MenuBarExtra` 改为 **NSStatusItem + main.swift** 原生方案（`MenuBarExtra` 在 swiftc 直接编译下不渲染图标）。
- 应用名由 `AutoSwitchInputMethod` 改为 **`AutoSwitchInput`**。
- 开关颜色由系统蓝改为深灰（`Toggle` 的 `.tint()` 控制开态，而非 `.accentColor()`）。
- 编译目标锁定 **arm64-apple-macosx14.0**，部署到 `/Applications`。

### 修复
- 主窗口首次打开时尺寸塌缩为 0 宽。
- 主窗口液态玻璃被渲染成透明椭圆（`.glassEffect()` 默认 capsule 形状）→ 改为 `.glassEffect(in: .rect(cornerRadius:))`。
- 关闭主窗口后再点 Dock 无法重开（旧窗口强引用残留）→ 关闭后重建干净窗口。

---

## 说明

- 本仓库无语义化版本号发布记录，变更以日期里程碑归档。
- 输入法切换依赖系统输入监控 / 辅助功能授权。
