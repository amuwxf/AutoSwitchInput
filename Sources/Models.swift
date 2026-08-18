import Foundation

/// App-to-input-method mapping rule
struct AppRule: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var bundleIdentifier: String
    var appName: String
    var inputSourceID: String
    var inputSourceName: String
}
