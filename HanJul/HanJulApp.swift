import SwiftUI
import SwiftData

@main struct HanJulApp: App {
    init() {
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
