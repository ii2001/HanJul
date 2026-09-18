import Foundation
import OSLog

enum AnalyticsEvent: String, Encodable {
    case appOpen = "app_open"
    case favoriteToggle = "favorite_toggle"
    case notificationToggle = "notification_toggle"
    case musicPlay = "music_play"
    case musicPause = "music_pause"
}

enum AnalyticsService {
    static let enabledKey = "analyticsEnabled"
    static let installIDKey = "anonymous_install_id"

    private static let endpoint = URL(string: "https://ziohvyfnlttuxowplghb.supabase.co/rest/v1/analytics_events")!
    private static let publishableKey = "sb_publishable_OAI9-vsWzW_qvQzOjJMlHw_r54RzgDq"
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HanJul", category: "analytics")

    private struct Payload: Encodable {
        let eventName: AnalyticsEvent
        let appVersion: String
        let anonymousInstallID: UUID
        let platform = "macOS"

        enum CodingKeys: String, CodingKey {
            case eventName = "event_name"
            case appVersion = "app_version"
            case anonymousInstallID = "anonymous_install_id"
            case platform
        }
    }

    static func configure(defaults: UserDefaults = .standard, makeUUID: () -> UUID = UUID.init) {
        defaults.register(defaults: [enabledKey: true])
        _ = anonymousInstallID(defaults: defaults, makeUUID: makeUUID)
    }

    static func isEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: enabledKey) as? Bool ?? true
    }

    static func anonymousInstallID(
        defaults: UserDefaults = .standard,
        makeUUID: () -> UUID = UUID.init
    ) -> UUID {
        if let stored = defaults.string(forKey: installIDKey),
           let identifier = UUID(uuidString: stored) {
            return identifier
        }

        let identifier = makeUUID()
        defaults.set(identifier.uuidString, forKey: installIDKey)
        return identifier
    }

    static func track(_ event: AnalyticsEvent) async {
        guard isEnabled() else { return }

        do {
            let (_, response) = try await URLSession.shared.data(for: makeRequest(for: event))
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
        } catch {
            logger.error("Analytics request failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    static func makeRequest(
        for event: AnalyticsEvent,
        defaults: UserDefaults = .standard,
        makeUUID: () -> UUID = UUID.init
    ) throws -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONEncoder().encode(Payload(
            eventName: event,
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
            anonymousInstallID: anonymousInstallID(defaults: defaults, makeUUID: makeUUID)
        ))
        return request
    }
}
