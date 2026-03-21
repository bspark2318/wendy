import Foundation

struct ChatRequestBody: Encodable {
    let message: String
    let user_id: String
}

struct ChatResponseBody: Decodable {
    let response: String
}

final class APIService {
    static let shared = APIService()
    private init() {}

    func sendMessage(_ message: String, userID: String = "ios_user") async throws -> String {
        guard Configuration.isConfigured else {
            throw APIError.notConfigured
        }

        guard let url = URL(string: "\(Configuration.apiBaseURL)/api/chat") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Configuration.apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 120

        let body = ChatRequestBody(message: message, user_id: userID)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(ChatResponseBody.self, from: data)
        return decoded.response
    }
}

enum APIError: LocalizedError {
    case notConfigured
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API not configured. Tap the gear icon to set your server URL and API key."
        case .invalidURL:
            return "Invalid server URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let code):
            return "Server error (HTTP \(code))."
        }
    }
}
