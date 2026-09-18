import Foundation
import XCTest
@testable import HanJul

final class AnalyticsServiceTests: XCTestCase {
    func test_requestContainsOnlyAllowlistedPayloadFields() throws {
        let request = try AnalyticsService.makeRequest(for: .favoriteToggle)
        let body = try XCTUnwrap(request.httpBody)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/rest/v1/analytics_events")
        XCTAssertEqual(Set(payload.keys), ["event_name", "app_version", "platform"])
        XCTAssertEqual(payload["event_name"], "favorite_toggle")
        XCTAssertEqual(payload["platform"], "macOS")
    }
}
