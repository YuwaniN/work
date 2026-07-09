import Foundation
import UserNotifications

struct NotificationService {
    /// Requests notification permission.
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedules (or reschedules) a daily notification at the given hour/minute.
    static func scheduleDaily(at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        // Remove existing daily challenge notifications
        center.removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Your daily reflex challenge is waiting — jump in and play!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyChallenge", content: content, trigger: trigger)

        center.add(request)
    }

    /// Removes the scheduled daily notification.
    static func cancelDaily() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])
    }
}
