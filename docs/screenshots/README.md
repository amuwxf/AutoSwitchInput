# 截图 / Screenshots

本目录存放 AutoSwitchInput 的界面截图。

## 当前内容 / Current contents

- `main-window-mockup.svg` — **界面示意图（Mockup）**，用于 README 预览，风格与真实 UI 一致（深灰主题 + 液态玻璃卡片 + 规则行）。

## 如何替换为真实截图 / How to replace with real screenshots

1. 启动应用：`open /Applications/AutoSwitchInput.app`
2. 确保主窗口可见（点 Dock 图标或菜单栏图标打开）。
3. 截取主窗口：
   - 快捷键 `Shift + Command + 4`，再按 `空格` 进入「窗口截图」模式，点击主窗口。
   - 或在终端运行：`screencapture -l <窗口ID> main-window.png`
4. 将生成的 PNG 重命名为 `main-window.png`（及按需的 `rules-section.png`）放入本目录。
5. 更新 `README.md` 中「界面预览 / Preview」的引用，把 `main-window-mockup.svg` 换成真实图片路径。

> 真实截图文件名建议使用 `main-window.png`（主窗口）与 `add-rule.png`（添加规则弹窗）。
> Prefer `main-window.png` (main window) and `add-rule.png` (add-rule sheet) for real captures.
