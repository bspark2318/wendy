import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await APIService.shared.sendMessage(text)
                let assistantMessage = ChatMessage(role: .assistant, content: response)
                messages.append(assistantMessage)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
