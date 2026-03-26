import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var dailyContent: DailyContent?
    @Published var featuredGames: [Game] = []
    @Published var isLoading = false

    func load() async {
        isLoading = true

        do {
            async let content = APIService.shared.getDailyContent()
            async let games = APIService.shared.getFeaturedGames()

            let (fetchedContent, fetchedGames) = try await (content, games)
            dailyContent = fetchedContent
            featuredGames = fetchedGames
        } catch {
            // Offline fallback
            let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
            if let cached = DatabaseService.shared.getCachedDailyContent(for: String(today)) {
                dailyContent = cached
            }
        }

        isLoading = false
    }
}
