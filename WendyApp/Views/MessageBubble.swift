import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }
    private var isError: Bool { message.role == .error }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Text(message.content)
                .padding(12)
                .background(bubbleBackground)
                .foregroundStyle(bubbleForeground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if !isUser { Spacer(minLength: 60) }
        }
    }

    private var bubbleBackground: Color {
        if isUser { return .blue }
        if isError { return Color.red.opacity(0.15) }
        return Color(.systemGray5)
    }

    private var bubbleForeground: Color {
        if isUser { return .white }
        if isError { return .red }
        return Color.primary
    }
}
