import Foundation

struct Configuration {
    static let apiBaseURL = "https://prod.wendy-gets-shit-done.today"

    static var apiKey: String {
        UserDefaults.standard.string(forKey: "api_key")
            ?? Bundle.main.infoDictionary?["WendyAPIKey"] as? String
            ?? ""
    }

    static var isConfigured: Bool {
        !apiKey.isEmpty
    }

    static func save(apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: "api_key")
    }
}
