import SwiftUI
import WidgetKit

private struct HanJulEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

private struct HanJulProvider: TimelineProvider {
    private static let fallback = Quote(
        id: "fallback",
        text: "오늘도 한 줄의 여유를 가져보세요.",
        author: "한줄"
    )

    func placeholder(in context: Context) -> HanJulEntry {
        HanJulEntry(date: .now, quote: Self.fallback)
    }

    func getSnapshot(in context: Context, completion: @escaping (HanJulEntry) -> Void) {
        completion(entry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HanJulEntry>) -> Void) {
        let now = Date.now
        let nextMidnight = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Calendar.current.startOfDay(for: now)
        ) ?? now.addingTimeInterval(86_400)
        completion(Timeline(entries: [entry(for: now)], policy: .after(nextMidnight)))
    }

    private func entry(for date: Date) -> HanJulEntry {
        let quote = (try? QuoteRepository()).map {
            DailyQuoteService(repository: $0).quote(for: date)
        } ?? Self.fallback
        return HanJulEntry(date: date, quote: quote)
    }
}

private struct HanJulWidgetView: View {
    let entry: HanJulEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "quote.opening")
                .foregroundStyle(.secondary)

            Text(entry.quote.text)
                .font(.headline)
                .lineLimit(4)

            Spacer(minLength: 0)

            Text(entry.quote.author)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct HanJulWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HanJulWidget", provider: HanJulProvider()) { entry in
            HanJulWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 한 줄")
        .description("매일 새로운 한국어 명언을 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
