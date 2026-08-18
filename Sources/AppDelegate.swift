import AppKit
import SwiftUI

/// AppKit delegate: owns the status-bar item, the menu, and the settings window.
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var settingsWindow: NSWindow?
    private var settingsHostingController: NSHostingController<SettingsView>?
    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupMonitor()
        RuleStore.shared.applyLaunchAtLogin() // 同步开机启动（登录项）状态
        setupKeyMonitor() // ⌘W 关闭主窗口（不退出应用）
        showSettings() // 启动即打开设置窗口，便于首次配置
    }

    // 点击 Dock 图标时打开设置窗口（应用改为 regular 模式后生效）
    func applicationShouldHandleReopen(_ sender: NSApplication) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        showSettings()
        return true
    }

    // 部分 macOS 版本/场景下点击 Dock 走此分支，同样打开主窗口
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        showSettings()
        return true
    }

    // MARK: - 键盘快捷键

    /// ⌘W：关闭主窗口（与红圈按钮同效），应用不退出，可经 Dock 图标再次打开。
    private func setupKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers?.lowercased() == "w" {
                // 仅当主窗口为 key 且未弹出 sheet（如"添加规则"）时关闭主窗口，
                // 避免连带关掉 sheet 或误触。
                if let win = self?.settingsWindow, win.isKeyWindow, win.attachedSheet == nil {
                    win.performClose(nil)
                    return nil
                }
            }
            return event
        }
    }

    // MARK: - Status Bar

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // 标准模板图标：符合 macOS HIG（菜单栏扩展应使用模板图标），自动适配浅/深色菜单栏
            if let image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "输入法自动切换") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "IME"
            }
            // 左键点击直接打开主窗口；右键弹出菜单
            button.target = self
            button.action = #selector(statusBarClicked(_:))
            _ = button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        rebuildMenu()
    }

    private func rebuildMenu() {
        guard statusItem != nil else { return }
        let menu = NSMenu()

        // Auto-switch toggle
        let toggle = NSMenuItem(
            title: "自动切换：\(RuleStore.shared.autoSwitchEnabled ? "开" : "关")",
            action: #selector(toggleAutoSwitch),
            keyEquivalent: ""
        )
        toggle.target = self
        menu.addItem(toggle)

        menu.addItem(.separator())

        // Current app + input method info
        if let name = AppMonitor.shared.currentAppName {
            let appItem = NSMenuItem(title: "当前应用：\(name)", action: nil, keyEquivalent: "")
            appItem.isEnabled = false
            menu.addItem(appItem)

            if let rule = AppMonitor.shared.currentBundleID.flatMap({ RuleStore.shared.rule(for: $0) }) {
                let ruleItem = NSMenuItem(title: "规则输入法：\(rule.inputSourceName)", action: nil, keyEquivalent: "")
                ruleItem.isEnabled = false
                menu.addItem(ruleItem)
            } else {
                let noRule = NSMenuItem(title: "无匹配规则", action: nil, keyEquivalent: "")
                noRule.isEnabled = false
                menu.addItem(noRule)
            }

            if let id = InputMethodManager.shared.getCurrentInputSourceID() {
                let cur = NSMenuItem(title: "当前输入法：\(InputMethodManager.shared.name(for: id))",
                                     action: nil, keyEquivalent: "")
                cur.isEnabled = false
                menu.addItem(cur)
            }
        }

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "设置…", action: #selector(showSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        let quit = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusMenu = menu
    }

    // MARK: - Monitor

    private func setupMonitor() {
        AppMonitor.shared.onAppChange = { [weak self] bundleID, appName in
            self?.handleAppChange(bundleID: bundleID, appName: appName)
            self?.rebuildMenu()
        }
        AppMonitor.shared.start()

        // Apply rule for the app that was frontmost at launch
        if let bundleID = AppMonitor.shared.currentBundleID {
            handleAppChange(bundleID: bundleID, appName: AppMonitor.shared.currentAppName ?? "")
        }
    }

    private func handleAppChange(bundleID: String, appName: String) {
        guard RuleStore.shared.autoSwitchEnabled else { return }
        if let rule = RuleStore.shared.rule(for: bundleID) {
            InputMethodManager.shared.selectInputSource(id: rule.inputSourceID)
        } else if let defaultID = RuleStore.shared.defaultInputSourceID {
            InputMethodManager.shared.selectInputSource(id: defaultID)
        }
    }

    // 状态栏按钮点击：左键打开主窗口，右键弹出菜单
    @objc private func statusBarClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            showSettings()
            return
        }
        let isRightClick = event.type == .rightMouseUp || event.modifierFlags.contains(.control)
        if isRightClick {
            rebuildMenu()
            if let menu = statusMenu {
                let point = NSPoint(x: 0, y: NSHeight(sender.bounds) + 4)
                menu.popUp(positioning: nil, at: point, in: sender)
            }
        } else {
            showSettings()
        }
    }

    // MARK: - Menu Actions

    @objc private func toggleAutoSwitch() {
        RuleStore.shared.autoSwitchEnabled.toggle()
        rebuildMenu()
    }

    @objc private func showSettings() {
        // 若窗口已被用户关闭（仍在内存中但不可见且未最小化），重建一个干净窗口，
        // 避免旧窗口残留状态导致再次点击 Dock 图标无法显示主窗口。
        if let w = settingsWindow, !w.isVisible {
            if w.isMiniaturized {
                w.deminiaturize(nil)
                return
            }
            w.close()
            settingsWindow = nil
            settingsHostingController = nil
        }

        if settingsWindow == nil {
            let hosting = NSHostingController(rootView: SettingsView())
            hosting.preferredContentSize = NSSize(width: 720, height: 540)
            settingsHostingController = hosting

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 720, height: 540),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            // 液态玻璃窗口（macOS 26 Tahoe）：
            // 内容视图换成 NSVisualEffectView（.hudWindow 材质），SwiftUI 视图悬浮其上
            if #available(macOS 26.0, *) {
                window.isOpaque = false
                window.backgroundColor = .clear
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)

                let effect = NSVisualEffectView()
                effect.material = .hudWindow
                effect.blendingMode = .behindWindow
                effect.state = .active
                window.contentView = effect

                hosting.view.frame = effect.bounds
                hosting.view.autoresizingMask = [.width, .height]
                effect.addSubview(hosting.view)
            } else {
                window.contentViewController = hosting
            }
            window.setContentSize(NSSize(width: 720, height: 540))
            window.contentMinSize = NSSize(width: 560, height: 420)
            window.title = "AutoSwitchInput - 设置"
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
