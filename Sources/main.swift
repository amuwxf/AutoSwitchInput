import AppKit

// Classic AppKit entry point.
// The app is an accessory app (LSUIElement = true in Info.plist) and lives
// only in the menu bar. AppDelegate owns the NSStatusItem and the settings window.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
