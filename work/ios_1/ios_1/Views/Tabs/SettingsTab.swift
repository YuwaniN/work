import SwiftUI

struct SettingsTab: View {
    @State private var notificationsEnabled = false
    @State private var challengeHour = 9
    @State private var challengeMinute = 0
    @State private var showResetConfirmation = false
    @State private var showNotificationAlert = false
    @State private var notificationAlertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Notifications
                Section {
                    Toggle("Daily Challenge Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            Task {
                                if newValue {
                                    let granted = await NotificationService.requestPermission()
                                    if granted {
                                        NotificationService.scheduleDaily(at: challengeHour, minute: challengeMinute)
                                    } else {
                                        notificationAlertMessage = "Please enable notifications in System Settings to receive daily challenges."
                                        showNotificationAlert = true
                                        notificationsEnabled = false
                                    }
                                } else {
                                    NotificationService.cancelDaily()
                                }
                            }
                        }

                    if notificationsEnabled {
                        DatePicker(
                            "Daily Time",
                            selection: Binding(
                                get: {
                                    Calendar.current.date(
                                        bySettingHour: challengeHour,
                                        minute: challengeMinute,
                                        second: 0,
                                        of: Date()
                                    ) ?? Date()
                                },
                                set: { date in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    challengeHour = components.hour ?? 9
                                    challengeMinute = components.minute ?? 0
                                    NotificationService.scheduleDaily(at: challengeHour, minute: challengeMinute)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Label("Daily Challenge", systemImage: "bell")
                }

                // MARK: - Light It Up
                Section {
                    let roundLength = Binding(
                        get: { UserDefaults.standard.integer(forKey: "roundLength").nonZero ?? 60 },
                        set: { UserDefaults.standard.set($0, forKey: "roundLength") }
                    )

                    Picker("Round Length", selection: roundLength) {
                        Text("30s").tag(30)
                        Text("60s").tag(60)
                        Text("90s").tag(90)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Label("Light It Up", systemImage: "bolt")
                } footer: {
                    Text("Applies the next time you start a round.")
                }

                // MARK: - Reset
                Section {
                    Button("Reset All Stats", role: .destructive) {
                        showResetConfirmation = true
                    }
                } header: {
                    Label("Data", systemImage: "trash")
                }
            }
            .navigationTitle("Settings")
            .alert("Notifications", isPresented: $showNotificationAlert) {
                Button("OK") {}
            } message: {
                Text(notificationAlertMessage)
            }
            .confirmationDialog(
                "Reset All Stats",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    GameSessionStore.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all game sessions and high scores.")
            }
        }
    }
}

private extension Int {
    /// Returns `self` if non-zero, otherwise `other`.
    var nonZero: Int? {
        self == 0 ? nil : self
    }
}

#Preview {
    SettingsTab()
}
