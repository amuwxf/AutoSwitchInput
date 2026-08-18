import AppKit

/// Monitors frontmost app changes via NSWorkspace notifications.
class AppMonitor {
    static let shared = AppMonitor()

    /// Called with (bundleIdentifier, appName) when the frontmost app changes.
    var onAppChange: ((String, String) -> Void)?

    private(set) var currentBundleID: String?
    private(set) var currentAppName: String?
    private var observer: NSObjectProtocol?
    private var debounceTimer: Timer?

    func start() {
        // Capture the app that was active at launch
        if let app = NSWorkspace.shared.frontmostApplication {
            currentBundleID = app.bundleIdentifier
            currentAppName = app.localizedName
        }

        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            else { return }

            let bundleID = app.bundleIdentifier ?? ""
            let name = app.localizedName ?? ""

            // Only fire when the frontmost app actually changes
            guard bundleID != self.currentBundleID else { return }
            self.currentBundleID = bundleID
            self.currentAppName = name

            // Debounce: wait 80ms to skip rapid app switching
            self.debounceTimer?.invalidate()
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: false) { [weak self] _ in
                self?.onAppChange?(bundleID, name)
            }
        }
    }

    func stop() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            self.observer = nil
        }
        debounceTimer?.invalidate()
    }
}
