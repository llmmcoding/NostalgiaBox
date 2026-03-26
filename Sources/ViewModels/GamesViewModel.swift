import Foundation

@MainActor
final class GamesViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var featuredGames: [Game] = []
    @Published var selectedCategory: GameCategory = .all
    @Published var isLoading = false
    @Published var errorMessage: String?

    enum GameCategory: String, CaseIterable {
        case all = "全部"
        case molabel = "魔塔"
        case pixel = "像素RPG"
        case runner = "跑酷"
        case puzzle = "休闲益智"

        var emoji: String {
            switch self {
            case .all: return "🎯"
            case .molabel: return "🏰"
            case .pixel: return "⚔️"
            case .runner: return "🏃"
            case .puzzle: return "🧩"
            }
        }
    }

    var filteredGames: [Game] {
        if selectedCategory == .all {
            return games
        }
        return games.filter { $0.category == selectedCategory.rawValue }
    }

    func loadGames() async {
        isLoading = true
        errorMessage = nil

        // Try online first
        do {
            async let onlineGames = APIService.shared.getGames()
            async let onlineFeatured = APIService.shared.getFeaturedGames()

            let (fetchedGames, fetchedFeatured) = try await (onlineGames, onlineFeatured)
            games = fetchedGames
            featuredGames = fetchedFeatured

            // Cache locally
            DatabaseService.shared.cacheGames(fetchedGames)
        } catch {
            // Fallback to cache
            let cached = DatabaseService.shared.getCachedGames()
            if !cached.isEmpty {
                games = cached
                featuredGames = cached.filter { $0.isFeatured }
                errorMessage = "离线模式（使用缓存数据）"
            } else {
                errorMessage = "无法加载游戏：\(error.localizedDescription)"
            }
        }

        isLoading = false
    }

    func refresh() async {
        await loadGames()
    }
}
