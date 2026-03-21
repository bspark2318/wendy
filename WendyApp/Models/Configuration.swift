import Foundation

struct Configuration {
    static var apiBaseURL: String {
        UserDefaults.standard.string(forKey: "api_base_url") ?? ""
    }

    static var apiKey: String {
        UserDefaults.standard.string(forKey: "api_key") ?? ""
    }

    static var isConfigured: Bool {
        !apiBaseURL.isEmpty && !apiKey.isEmpty
    }

    static func save(baseURL: String, apiKey: String) {
        UserDefaults.standard.set(baseURL, forKey: "api_base_url")
        UserDefaults.standard.set(apiKey, forKey: "api_key")
    }
}
