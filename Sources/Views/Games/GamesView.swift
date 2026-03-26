import SwiftUI

struct GamesView: View {
    @StateObject private var viewModel = GamesViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(GamesViewModel.GameCategory.allCases, id: \.self) { cat in
                            CategoryChip(
                                title: "\(cat.emoji) \(cat.rawValue)",
                                isSelected: viewModel.selectedCategory == cat
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedCategory = cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("加载中...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("重试") {
                            Task { await viewModel.loadGames() }
                        }
                        .buttonStyle(.bordered)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(viewModel.filteredGames) { game in
                                NavigationLink(value: game) {
                                    GameCardView(game: game)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("游戏")
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
            .searchable(text: $searchText, prompt: "搜索游戏")
            .task {
                await viewModel.loadGames()
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct GameCardView: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: game.color).opacity(0.7), Color(hex: game.color).opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(16/9, contentMode: .fit)
                .overlay {
                    Text(game.emoji)
                        .font(.system(size: 40))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(game.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack {
                    Text(game.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(game.difficulty.rawValue)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color(hex: game.difficulty.color))
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct GameDetailView: View {
    let game: Game
    @State private var isPlaying = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: game.color).opacity(0.7), Color(hex: game.color).opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay {
                        VStack {
                            Text(game.emoji)
                                .font(.system(size: 80))
                            Text(game.title)
                                .font(.title.bold())
                                .foregroundStyle(.white)
                        }
                    }

                VStack(spacing: 12) {
                    HStack {
                        DifficultyBadge(difficulty: game.difficulty)
                        Spacer()
                        Text(game.category)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(game.description)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                // Play Button
                Button {
                    isPlaying = true
                } label: {
                    Label("开始游戏", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: game.color))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $isPlaying) {
                    GamePlayerView(game: game)
                }

                // Locked indicator if not unlocked
                if !appState.isUnlocked {
                    Text("解锁完整版后可玩全部游戏")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text(difficulty.rawValue)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(Color(hex: difficulty.color))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: difficulty.color).opacity(0.15))
        .clipShape(Capsule())
    }
}

struct GamePlayerView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color(hex: game.color).opacity(0.3).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(game.title)
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 30)
                }
                .padding()

                Spacer()

                if appState.isUnlocked {
                    if game.gameUrl.isEmpty {
                        VStack(spacing: 12) {
                            Text(game.emoji)
                                .font(.system(size: 100))
                            Text("游戏加载中...")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Web游戏即将上线")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        // WebView would load game.gameUrl here
                        Text("游戏界面")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("解锁完整版后游玩")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("提示：完整版包含全部游戏")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
        }
    }
}

// Color hex extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GamesView()
        .environmentObject(AppState.shared)
}
