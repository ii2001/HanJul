import AppIntents
import SwiftUI
import WidgetKit

private enum WidgetArtwork: String, AppEnum {
    case daily
    case dawn
    case moon
    case spring
    case autumn
    case winter
    case hidden

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "배경 이미지")
    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .daily: "매일 자동 변경",
        .dawn: "안개 산",
        .moon: "달빛 호수",
        .spring: "봄꽃",
        .autumn: "가을 들판",
        .winter: "겨울 숲",
        .hidden: "배경 없음"
    ]

    var artwork: QuoteArtwork {
        QuoteArtwork(rawValue: rawValue) ?? .daily
    }
}

private struct HanJulConfiguration: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "한줄 위젯 설정"

    @Parameter(title: "배경", default: .daily)
    var artwork: WidgetArtwork
}

private struct HanJulEntry: TimelineEntry {
    let date: Date
    let quote: Quote
    let artwork: QuoteArtwork
}

private struct HanJulProvider: AppIntentTimelineProvider {
    private static let fallback = Quote(
        id: "fallback",
        text: "오늘도 한 줄의 여유를 가져보세요.",
        author: "한줄"
    )

    func placeholder(in context: Context) -> HanJulEntry {
        HanJulEntry(date: .now, quote: Self.fallback, artwork: .daily)
    }

    func snapshot(for configuration: HanJulConfiguration, in context: Context) async -> HanJulEntry {
        entry(for: .now, artwork: configuration.artwork.artwork)
    }

    func timeline(for configuration: HanJulConfiguration, in context: Context) async -> Timeline<HanJulEntry> {
        let now = Date.now
        let nextMidnight = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Calendar.current.startOfDay(for: now)
        ) ?? now.addingTimeInterval(86_400)
        return Timeline(
            entries: [entry(for: now, artwork: configuration.artwork.artwork)],
            policy: .after(nextMidnight)
        )
    }

    private func entry(for date: Date, artwork: QuoteArtwork) -> HanJulEntry {
        let quote = (try? QuoteRepository()).map {
            DailyQuoteService(repository: $0).quote(for: date)
        } ?? Self.fallback
        return HanJulEntry(date: date, quote: quote, artwork: artwork)
    }
}

private struct HanJulWidgetView: View {
    let entry: HanJulEntry

    var body: some View {
        ZStack {
            if let imageName = entry.artwork.imageName(for: entry.quote) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .accessibilityHidden(true)

                Color.white.opacity(0.58)
            }

            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .foregroundStyle(.black.opacity(0.55))

                Text(entry.quote.text)
                    .font(.headline)
                    .lineLimit(4)

                Spacer(minLength: 0)

                Text(entry.quote.author)
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .foregroundStyle(.black.opacity(0.82))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(Color(nsColor: .windowBackgroundColor), for: .widget)
    }
}

@main
struct HanJulWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "HanJulWidget",
            intent: HanJulConfiguration.self,
            provider: HanJulProvider()
        ) { entry in
            HanJulWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 한 줄")
        .description("매일 새로운 한국어 명언을 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
