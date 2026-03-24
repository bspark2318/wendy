import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String

    init() {
        _apiKey = State(initialValue: Configuration.apiKey)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Authentication") {
                    SecureField("API Key", text: $apiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Configuration.save(apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                }
            }
        }
    }
}
