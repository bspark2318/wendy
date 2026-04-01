import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var values: [AgentProfile: (url: String, key: String)] = {
        var dict: [AgentProfile: (String, String)] = [:]
        for agent in AgentProfile.allCases {
            dict[agent] = (
                Configuration.apiBaseURL(for: agent),
                Configuration.apiKey(for: agent)
            )
        }
        return dict
    }()

    var body: some View {
        NavigationStack {
            Form {
                ForEach(AgentProfile.allCases, id: \.self) { agent in
                    Section(agent.displayName) {
                        TextField("Base URL", text: binding(for: agent, keyPath: \.url))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)

                        SecureField("API Key", text: binding(for: agent, keyPath: \.key))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
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
                        for agent in AgentProfile.allCases {
                            guard let v = values[agent] else { continue }
                            Configuration.save(
                                baseURL: v.url.trimmingCharacters(in: .whitespacesAndNewlines),
                                for: agent
                            )
                            Configuration.save(
                                apiKey: v.key.trimmingCharacters(in: .whitespacesAndNewlines),
                                for: agent
                            )
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private func binding(
        for agent: AgentProfile,
        keyPath: WritableKeyPath<(url: String, key: String), String>
    ) -> Binding<String> {
        Binding(
            get: { values[agent]?[keyPath: keyPath] ?? "" },
            set: { values[agent]?[keyPath: keyPath] = $0 }
        )
    }
}
