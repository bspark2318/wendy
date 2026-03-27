import Foundation
import Combine
import UIKit

@MainActor
final class ChatViewModel: ObservableObject {
    private let maxStoredMessages = 30

    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published private(set) var hasSavedChat = false

    private var backgroundObserver: AnyCancellable?

    private static var saveFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("last_chat.json")
    }

    init() {
        hasSavedChat = FileManager.default.fileExists(atPath: Self.saveFileURL.path)

        backgroundObserver = NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in self?.saveMessages() }
            }
    }

    // MARK: - Persistence

    func saveMessages() {
        guard !messages.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: Self.saveFileURL, options: .atomic)
            hasSavedChat = true
        } catch {
            // Best-effort; nothing to surface to the user
        }
    }

    func loadPreviousMessages() {
        let url = Self.saveFileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            messages = try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch {
            try? FileManager.default.removeItem(at: url)
        }
        hasSavedChat = false
    }

    // MARK: - Sending

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
            saveMessages()
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
