import SwiftUI

struct SettingsView: View {
    @AppStorage("roundLength") private var roundLength = 60
    @Environment(\.dismiss) private var dismiss

    private let options = [30, 60, 90]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Round Length", selection: $roundLength) {
                        ForEach(options, id: \.self) { seconds in
                            Text("\(seconds)s").tag(seconds)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Light It Up")
                } footer: {
                    Text("Applies the next time you start a round.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
