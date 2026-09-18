import SwiftUI
import SwiftData
import WidgetKit

@main struct HanJulApp: App {
    init() {
        AnalyticsService.configure()
        WidgetCenter.shared.reloadAllTimelines()
        Task { await AnalyticsService.track(.appOpen) }
    }

    var body: some Scene {
        MenuBarExtra("한줄", systemImage: "quote.bubble") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: FavoriteQuote.self)
    }
}
