import Foundation
import AppKit
import ServiceManagement

/// Observable store for app rules and settings, persisted to UserDefaults.
class RuleStore: ObservableObject {
    static let shared = RuleStore()

    @Published var autoSwitchEnabled: Bool {
        didSet { save() }
    }
    @Published var rules: [AppRule] {
        didSet { save() }
    }
    @Published var defaultInputSourceID: String? {
        didSet { save() }
    }
    /// 是否开机启动（登录项）。写入 UserDefaults 并同步系统登录项状态。
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: launchKey)
            applyLaunchAtLogin()
        }
    }

    private let defaults = UserDefaults.standard
    private let rulesKey = "appRules"
    private let enabledKey = "autoSwitchEnabled"
    private let defaultKey = "defaultInputSourceID"
    private let launchKey = "launchAtLogin"
    private let firstLaunchKey = "hasLaunchedBefore"

    init() {
        autoSwitchEnabled = defaults.object(forKey: enabledKey) as? Bool ?? true
        defaultInputSourceID = defaults.string(forKey: defaultKey)
        launchAtLogin = defaults.bool(forKey: launchKey)

        if let data = defaults.data(forKey: rulesKey),
           let decoded = try? JSONDecoder().decode([AppRule].self, from: data) {
            rules = decoded
        } else {
            rules = []
        }

        // Seed default rules on first launch
        if !defaults.bool(forKey: firstLaunchKey) {
            if rules.isEmpty {
                rules = RuleStore.defaultRules()
            }
            defaults.set(true, forKey: firstLaunchKey)
        }
    }

    private func save() {
        defaults.set(autoSwitchEnabled, forKey: enabledKey)
        if let data = try? JSONEncoder().encode(rules) {
            defaults.set(data, forKey: rulesKey)
        }
        defaults.set(defaultInputSourceID, forKey: defaultKey)
    }

    /// 根据 launchAtLogin 同步系统的登录项（开机启动）状态。
    /// 使用 SMAppService.mainApp（macOS 13+），需要在 /Applications 中运行才生效。
    func applyLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if launchAtLogin {
                if service.status != .enabled {
                    try service.register()
                }
            } else {
                if service.status == .enabled {
                    try service.unregister()
                }
            }
        } catch {
            print("[RuleStore] 开机启动设置失败: \(error.localizedDescription)")
        }
    }

    /// Finds the rule matching the given bundle identifier.
    func rule(for bundleID: String) -> AppRule? {
        rules.first { $0.bundleIdentifier == bundleID }
    }

    /// Returns currently running regular apps (suitable for the picker).
    func runningApps() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }

    /// Default seed rules for common apps.
    static func defaultRules() -> [AppRule] {
        let abc = "com.apple.keylayout.ABC"
        let pinyin = "com.apple.inputmethod.SCIM.ITABC"
        return [
            // Dev tools → English
            AppRule(bundleIdentifier: "com.apple.Terminal",
                    appName: "Terminal",
                    inputSourceID: abc,
                    inputSourceName: "ABC"),
            AppRule(bundleIdentifier: "com.googlecode.iterm2",
                    appName: "iTerm2",
                    inputSourceID: abc,
                    inputSourceName: "ABC"),
            AppRule(bundleIdentifier: "com.microsoft.VSCode",
                    appName: "VS Code",
                    inputSourceID: abc,
                    inputSourceName: "ABC"),
            AppRule(bundleIdentifier: "com.apple.dt.Xcode",
                    appName: "Xcode",
                    inputSourceID: abc,
                    inputSourceName: "ABC"),
            AppRule(bundleIdentifier: "com.todesktop.230313mzl4w4u92",
                    appName: "Warp",
                    inputSourceID: abc,
                    inputSourceName: "ABC"),
            // Communication apps → Chinese
            AppRule(bundleIdentifier: "com.tencent.xinWeChat",
                    appName: "WeChat",
                    inputSourceID: pinyin,
                    inputSourceName: "Pinyin – Simplified"),
        ]
    }
}
