import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    /// Oldest messages are dropped so memory and scroll cost stay bounded.
    private let maxStoredMessages = 30

    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        appendMessage(userMessage)
        inputText = ""
        isLoading = true

        Task { @MainActor in
            do {
                let response = try await APIService.shared.sendMessage(text)
                let assistantMessage = ChatMessage(role: .assistant, content: response)
                appendMessage(assistantMessage)
            } catch {
                let explanation = Self.describeError(error)
                appendMessage(ChatMessage(role: .error, content: "Something went wrong: \(explanation)"))
            }
            isLoading = false
        }
    }

    private func appendMessage(_ message: ChatMessage) {
        messages.append(message)
        if messages.count > maxStoredMessages {
            messages.removeFirst(messages.count - maxStoredMessages)
        }
    }

    private static func describeError(_ error: Error) -> String {
        if let api = error as? APIError {
            return api.errorDescription ?? String(describing: api)
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection."
            case .timedOut:
                return "Request timed out."
            case .cannotFindHost, .cannotConnectToHost:
                return "Can't reach the server. Check the URL in Settings."
            default:
                return urlError.localizedDescription
            }
        }
        if error is DecodingError {
            return "The server sent a response this app couldn't read."
        }
        return error.localizedDescription
    }
}
