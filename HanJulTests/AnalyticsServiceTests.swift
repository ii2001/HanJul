import Foundation
import XCTest
@testable import HanJul

final class AnalyticsServiceTests: XCTestCase {
    func test_requestContainsOnlyAllowlistedPayloadFields() throws {
        let defaults = try makeDefaults()
        let identifier = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let request = try AnalyticsService.makeRequest(
            for: .favoriteToggle,
            defaults: defaults,
            makeUUID: { identifier }
        )
        let body = try XCTUnwrap(request.httpBody)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/rest/v1/analytics_events")
        XCTAssertEqual(Set(payload.keys), ["event_name", "app_version", "anonymous_install_id", "platform"])
        XCTAssertEqual(payload["event_name"], "favorite_toggle")
        XCTAssertEqual(payload["anonymous_install_id"], identifier.uuidString)
        XCTAssertEqual(payload["platform"], "macOS")
    }

    func test_analyticsDefaultsOnAndCanBeDisabled() throws {
        let defaults = try makeDefaults()
        let identifier = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!

        AnalyticsService.configure(defaults: defaults, makeUUID: { identifier })

        XCTAssertTrue(AnalyticsService.isEnabled(defaults: defaults))
        XCTAssertEqual(defaults.string(forKey: AnalyticsService.installIDKey), identifier.uuidString)
        defaults.set(false, forKey: AnalyticsService.enabledKey)
        XCTAssertFalse(AnalyticsService.isEnabled(defaults: defaults))
    }

    func test_installIdentifierIsGeneratedOnceAndReused() throws {
        let defaults = try makeDefaults()
        let first = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let second = UUID(uuidString: "66666666-7777-8888-9999-AAAAAAAAAAAA")!

        XCTAssertEqual(AnalyticsService.anonymousInstallID(defaults: defaults, makeUUID: { first }), first)
        XCTAssertEqual(AnalyticsService.anonymousInstallID(defaults: defaults, makeUUID: { second }), first)
    }

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "AnalyticsServiceTests.\(UUID().uuidString)"
        return try XCTUnwrap(UserDefaults(suiteName: suiteName))
    }
}
