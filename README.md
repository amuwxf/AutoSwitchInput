# AutoSwitchInput

> 按应用自动切换 macOS 输入法的菜单栏小工具。

---

## 简介

AutoSwitchInput 是一个纯原生的 macOS 菜单栏应用。当你在不同 App 之间切换时，它会按照预设规则自动把输入法切到对应状态：比如终端类应用一律用英文（ABC），微信这类聊天应用自动切到中文拼音。告别反复手动切换输入法的烦恼。

---

## 功能特性

- **按应用自动切换** — 监听前台 App 切换，80ms 防抖后匹配规则并切换输入法。
- **规则化管理** — 每条规则 = 应用（Bundle ID）+ 目标输入法，支持下拉选择、即时生效。
- **内置默认规则** — 首次启动自动写入：Terminal / iTerm2 / VS Code / Xcode / Warp → ABC（英文）；微信 → 拼音（简体）。
- **纯菜单栏后台** — 无 Dock 图标，仅顶部菜单栏常驻图标；启动与关闭窗口都安静留在后台，点击图标随时打开主窗口。
- **液态玻璃界面** — 在 macOS 26 (Tahoe) 上呈现系统原生液态玻璃质感（窗口材质 + 卡片玻璃 + 规则行玻璃），旧系统自动回退为毛玻璃。
- **深灰主题** — 统一深灰强调色与 Dock 图标，取代默认蓝色。
- **开机启动** — 通用设置中一键开启「登录后自动运行」。
- **⌘W 关闭窗口** — 关闭主窗口后应用常驻菜单栏，点菜单栏图标可随时重新打开。

---

## 系统要求

- macOS 14.0 或更高
- Apple Silicon（arm64）
- 输入法切换依赖系统授权，首次使用可能需在 **系统设置 › 隐私与安全性 › 输入监控 / 辅助功能** 中允许本应用。
- 若从源码构建，需要 **Xcode 命令行工具**（`xcode-select --install`）。

---

## 安装

**方式一：源码构建（推荐）**

```bash
cd AutoSwitchInput
bash build.sh
open /Applications/AutoSwitchInput.app
```

`build.sh` 会编译 arm64 二进制、打包为 `.app`、ad-hoc 签名，并自动部署到 `/Applications`。

**方式二：直接运行工作区构建**

```bash
cd AutoSwitchInput
bash build.sh
open AutoSwitchInput.app
```

> 若 macOS 拦截未签名应用：系统设置 › 隐私与安全性 › 仍要打开。

---

## 使用

1. 启动后安静留在后台（菜单栏图标常驻），点击菜单栏图标打开主窗口；窗口关闭后应用依然常驻后台。
2. **通用**
   - 启用自动切换：总开关。
   - 默认输入法：无匹配规则时的兜底输入法。
   - 开机启动：登录后自动运行。
3. **应用规则**
   - 每行一个应用，右侧下拉选择目标输入法，垃圾桶图标删除规则。
   - 点击「添加规则」从正在运行的 App 中选择。
4. 切换应用即可看到输入法自动跟随规则变化。

---

## 界面预览

> 下图为界面示意图，风格与真实运行效果一致；真实截图见 [docs/screenshots](./docs/screenshots)。

![AutoSwitchInput 主窗口示意](./docs/screenshots/main-window.png)

---

## 项目结构

```
AutoSwitchInput/
├── Sources/
│   ├── main.swift              # AppKit 入口，驱动 AppDelegate（替代 @main）
│   ├── AppDelegate.swift       # 状态栏、窗口、⌘W、Dock 重开逻辑
│   ├── AppMonitor.swift        # 监听前台 App 切换
│   ├── InputMethodManager.swift # Carbon TIS API 封装
│   ├── RuleStore.swift         # 规则持久化（UserDefaults）+ 开机启动
│   ├── SettingsView.swift      # SwiftUI 主界面（液态玻璃）
│   └── Design.swift            # 设计令牌与 LiquidGlass 修饰符
├── Resources/
│   ├── Info.plist
│   ├── AppIcon.icns            # 深灰键盘 Dock 图标
│   └── icon_src/gen_dock_icon.swift  # 图标生成脚本
├── build.sh                    # 编译 + 打包 + 部署脚本
├── LICENSE                     # GPLv3
├── README.md                   # 中文文档
└── README_EN.md                # English documentation
```

---

## 技术栈

Swift 6 · SwiftUI · AppKit · Carbon TIS API · `swiftc` 直接编译（无 Xcode 工程）· ad-hoc 签名 · `SMAppService.mainApp` 登录项。

---

## 许可证

本项目以 **GNU General Public License v3.0 (GPLv3)** 开源。详见 [LICENSE](./LICENSE)。
