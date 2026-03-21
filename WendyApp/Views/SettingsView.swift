import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var baseURL: String
    @State private var apiKey: String

    init() {
        _baseURL = State(initialValue: Configuration.apiBaseURL)
        _apiKey = State(initialValue: Configuration.apiKey)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("Base URL (e.g. https://wendy.example.com)", text: $baseURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

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
                        Configuration.save(baseURL: baseURL.trimmingCharacters(in: .whitespacesAndNewlines),
                                           apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                }
            }
        }
    }
}
