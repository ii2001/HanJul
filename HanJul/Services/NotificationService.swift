import UserNotifications

enum NotificationService {
    static let requestIdentifier = "daily-quote"

    static func update(enabled: Bool, hour: Int, minute: Int) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
        guard enabled else { return false }

        let granted = try await center.requestAuthorization(options: [.alert, .sound])
        guard granted else { return false }

        let content = UNMutableNotificationContent()
        content.title = "오늘의 한 줄"
        content.body = "오늘의 명언을 확인해 보세요."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        try await center.add(UNNotificationRequest(
            identifier: requestIdentifier,
            content: content,
            trigger: trigger
        ))
        return true
    }
}
