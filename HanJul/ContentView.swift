import AppKit
import OSLog
import SwiftData
import SwiftUI

struct ContentView: View {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HanJul", category: "app")

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteQuote.createdAt, order: .reverse) private var favorites: [FavoriteQuote]
    @AppStorage("notificationEnabled") private var notificationEnabled = false
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @AppStorage("analyticsEnabled") private var analyticsEnabled = false

    private let quote: Quote?
    private let loadError: String?

    init() {
        do {
            let repository = try QuoteRepository()
            quote = DailyQuoteService(repository: repository).quote()
            loadError = nil
        } catch {
            quote = nil
            loadError = "명언 데이터를 불러오지 못했습니다."
            Self.logger.error("Quote loading failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let quote {
                Text(quote.text)
                    .font(.title3.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("명언: \(quote.text)")

                Text("— \(quote.author)")
                    .foregroundStyle(.secondary)

                HStack {
                    Button {
                        toggleFavorite(quote)
                    } label: {
                        Label(isFavorite(quote) ? "즐겨찾기 해제" : "즐겨찾기", systemImage: isFavorite(quote) ? "heart.fill" : "heart")
                    }

                    Button {
                        copy(quote)
                    } label: {
                        Label("복사", systemImage: "doc.on.doc")
                    }
                }
                .buttonStyle(.borderless)
            } else {
                Label(loadError ?? "알 수 없는 오류가 발생했습니다.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }

            Divider()

            DisclosureGroup("즐겨찾기 \(favorites.count)개") {
                if favorites.isEmpty {
                    Text("저장한 명언이 없습니다.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(favorites) { favorite in
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(favorite.text)
                                        Text(favorite.author)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        modelContext.delete(favorite)
                                        Task { await AnalyticsService.track(.favoriteToggle) }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("즐겨찾기 삭제")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                    .padding(.top, 6)
                }
            }

            Divider()

            Toggle("매일 알림", isOn: notificationBinding)

            if notificationEnabled {
                DatePicker("알림 시간", selection: notificationTime, displayedComponents: .hourAndMinute)
            }

            Toggle("익명 사용 통계", isOn: analyticsBinding)

            Text("명언 내용과 개인 식별 정보는 전송하지 않습니다.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Button("한줄 종료") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 360)
    }

    private var notificationBinding: Binding<Bool> {
        Binding(
            get: { notificationEnabled },
            set: { enabled in
                Task { await updateNotification(enabled: enabled) }
            }
        )
    }

    private var notificationTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: notificationHour,
                    minute: notificationMinute,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                notificationHour = components.hour ?? 9
                notificationMinute = components.minute ?? 0
                Task { await updateNotification(enabled: true, trackEvent: false) }
            }
        )
    }

    private var analyticsBinding: Binding<Bool> {
        Binding(
            get: { analyticsEnabled },
            set: { enabled in
                analyticsEnabled = enabled
                if enabled {
                    Task { await AnalyticsService.track(.appOpen) }
                }
            }
        )
    }

    private func isFavorite(_ quote: Quote) -> Bool {
        favorites.contains { $0.quoteID == quote.id }
    }

    private func toggleFavorite(_ quote: Quote) {
        if let favorite = favorites.first(where: { $0.quoteID == quote.id }) {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(FavoriteQuote(quote: quote))
        }
        Task { await AnalyticsService.track(.favoriteToggle) }
    }

    private func copy(_ quote: Quote) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("\"\(quote.text)\" — \(quote.author)", forType: .string)
    }

    @MainActor
    private func updateNotification(enabled: Bool, trackEvent: Bool = true) async {
        do {
            notificationEnabled = try await NotificationService.update(
                enabled: enabled,
                hour: notificationHour,
                minute: notificationMinute
            )
            if trackEvent {
                await AnalyticsService.track(.notificationToggle)
            }
        } catch {
            notificationEnabled = false
            Self.logger.error("Notification update failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoriteQuote.self, inMemory: true)
}
