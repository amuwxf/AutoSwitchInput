import Carbon
import AppKit

/// Wraps the Carbon TIS (Text Input Source) API for listing and selecting input methods.
class InputMethodManager {
    static let shared = InputMethodManager()

    struct InputSource: Identifiable, Hashable {
        let id: String   // TIS input source ID, e.g. "com.apple.keylayout.ABC"
        let name: String  // Localized display name, e.g. "ABC" or "简体拼音"
    }

    private var cache: [InputSource] = []
    private var cacheTime: Date?

    /// Returns all enabled keyboard input sources, sorted by name.
    func getAllInputSources() -> [InputSource] {
        // Cache for 5 seconds to avoid repeated Carbon calls
        if let cacheTime = cacheTime,
           Date().timeIntervalSince(cacheTime) < 5,
           !cache.isEmpty {
            return cache
        }

        guard let unmanaged = TISCreateInputSourceList(nil, false) else { return [] }
        let cfArray = unmanaged.takeRetainedValue()
        let count = CFArrayGetCount(cfArray)
        var sources: [InputSource] = []

        for i in 0..<count {
            let rawPtr = CFArrayGetValueAtIndex(cfArray, i)!
            let source = Unmanaged<TISInputSource>.fromOpaque(rawPtr).takeUnretainedValue()

            // Filter: only keyboard input sources
            if let catPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceCategory) {
                let category = Unmanaged<CFString>.fromOpaque(catPtr).takeUnretainedValue()
                if category != "TISCategoryKeyboardInputSource" as CFString { continue }
            }

            // Filter: only enabled sources
            if let enPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsEnabled) {
                let enabled = Unmanaged<CFBoolean>.fromOpaque(enPtr).takeUnretainedValue()
                if !CFBooleanGetValue(enabled) { continue }
            }

            // Get ID
            guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
            let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String

            // Get localized name
            guard let namePtr = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) else { continue }
            let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String

            sources.append(InputSource(id: id, name: name))
        }

        let sorted = sources.sorted { $0.name < $1.name }
        cache = sorted
        cacheTime = Date()
        return sorted
    }

    /// Selects the input source with the given ID. Returns true on success.
    @discardableResult
    func selectInputSource(id: String) -> Bool {
        guard let unmanaged = TISCreateInputSourceList(nil, false) else { return false }
        let cfArray = unmanaged.takeRetainedValue()
        let count = CFArrayGetCount(cfArray)

        for i in 0..<count {
            let rawPtr = CFArrayGetValueAtIndex(cfArray, i)!
            let source = Unmanaged<TISInputSource>.fromOpaque(rawPtr).takeUnretainedValue()

            guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
            let sourceID = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String

            if sourceID == id {
                let status = TISSelectInputSource(source)
                return status == noErr
            }
        }
        return false
    }

    /// Returns the ID of the currently selected input source.
    func getCurrentInputSourceID() -> String? {
        guard let unmanaged = TISCreateInputSourceList(nil, false) else { return nil }
        let cfArray = unmanaged.takeRetainedValue()
        let count = CFArrayGetCount(cfArray)

        for i in 0..<count {
            let rawPtr = CFArrayGetValueAtIndex(cfArray, i)!
            let source = Unmanaged<TISInputSource>.fromOpaque(rawPtr).takeUnretainedValue()

            if let selPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsSelected) {
                let selected = Unmanaged<CFBoolean>.fromOpaque(selPtr).takeUnretainedValue()
                if CFBooleanGetValue(selected) {
                    guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
                    return Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
                }
            }
        }
        return nil
    }

    /// Returns the display name for a given input source ID.
    func name(for id: String) -> String {
        getAllInputSources().first { $0.id == id }?.name ?? id
    }
}
