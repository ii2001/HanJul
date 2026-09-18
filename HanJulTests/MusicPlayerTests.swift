import Foundation
import XCTest
@testable import HanJul

final class MusicPlayerTests: XCTestCase {
    func test_dailyTrackSelectionHandlesMissingFilesAndStaysStable() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let morning = calendar.date(from: DateComponents(year: 2026, month: 9, day: 18, hour: 1))!
        let evening = calendar.date(from: DateComponents(year: 2026, month: 9, day: 18, hour: 23))!
        let tomorrow = calendar.date(from: DateComponents(year: 2026, month: 9, day: 19, hour: 1))!
        let tracks = [URL(fileURLWithPath: "/a.mp3"), URL(fileURLWithPath: "/b.mp3")]

        XCTAssertNil(LocalMusicLibrary.today(in: [], date: morning, calendar: calendar))
        XCTAssertEqual(
            LocalMusicLibrary.today(in: tracks, date: morning, calendar: calendar),
            LocalMusicLibrary.today(in: tracks, date: evening, calendar: calendar)
        )
        XCTAssertNotEqual(
            LocalMusicLibrary.today(in: tracks, date: morning, calendar: calendar),
            LocalMusicLibrary.today(in: tracks, date: tomorrow, calendar: calendar)
        )
    }
}
