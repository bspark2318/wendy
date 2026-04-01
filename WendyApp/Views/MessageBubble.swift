import MarkdownUI
import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }
    private var isError: Bool { message.role == .error }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Group {
                if isUser {
                    Text(message.content)
                } else {
                    Markdown(message.content)
                        .markdownTheme(bubbleMarkdownTheme)
                }
            }
            .textSelection(.enabled)
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

    private var bubbleMarkdownTheme: Theme {
        Theme()
            .code {
                FontFamilyVariant(.monospaced)
                FontSize(.em(0.88))
                BackgroundColor(Color(.systemGray4).opacity(0.5))
            }
            .codeBlock { configuration in
                ScrollView(.horizontal) {
                    configuration.label
                        .relativeLineSpacing(.em(0.2))
                        .markdownTextStyle {
                            FontFamilyVariant(.monospaced)
                            FontSize(.em(0.85))
                        }
                        .padding(12)
                }
                .background(Color(.systemGray4).opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .markdownMargin(top: 4, bottom: 4)
            }
    }
}
