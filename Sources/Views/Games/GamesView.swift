import SwiftUI

struct GamesView: View {
    @State private var selectedCategory: GameCategory = .all
    @State private var searchText = ""

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

    var filteredGames: [GameItem] {
        GameItem.all.filter { game in
            (selectedCategory == .all || game.category == selectedCategory.rawValue) &&
            (searchText.isEmpty || game.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(GameCategory.allCases, id: \.self) { cat in
                            CategoryChip(
                                title: "\(cat.emoji) \(cat.rawValue)",
                                isSelected: selectedCategory == cat
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Game Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(filteredGames) { game in
                            NavigationLink(value: game) {
                                GameCardView(game: game)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("游戏")
            .navigationDestination(for: GameItem.self) { game in
                GameDetailView(game: game)
            }
            .searchable(text: $searchText, prompt: "搜索游戏")
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
    let game: GameItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [game.color.opacity(0.6), game.color.opacity(0.3)],
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

                Text(game.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct GameItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let emoji: String
    let color: Color
    let description: String
    let difficulty: Difficulty

    enum Difficulty: String {
        case easy = "简单"
        case medium = "中等"
        case hard = "困难"
    }

    static let all: [GameItem] = [
        GameItem(title: "魔塔·黄金大陆", category: "魔塔", emoji: "🏰", color: .yellow, description: "经典魔塔复刻，50层挑战", difficulty: .medium),
        GameItem(title: "像素勇者", category: "像素RPG", emoji: "⚔️", color: .purple, description: "复古像素RPG，勇者救公主", difficulty: .medium),
        GameItem(title: "跳跳像素人", category: "跑酷", emoji: "🏃", color: .green, description: "无尽跑酷，像素风格", difficulty: .easy),
        GameItem(title: "宠物小精灵", category: "休闲益智", emoji: "🧩", color: .blue, description: "经典宠物收集游戏", difficulty: .easy),
        GameItem(title: "魔塔·暗黑森林", category: "魔塔", emoji: "🌲", color: .green, description: "暗黑森林魔塔副本", difficulty: .hard),
        GameItem(title: "龙之谷", category: "像素RPG", emoji: "🐉", color: .red, description: "龙与地下城风格像素RPG", difficulty: .hard),
        GameItem(title: "方块跑酷", category: "跑酷", emoji: "🟧", color: .orange, description: "几何方块跑酷游戏", difficulty: .easy),
        GameItem(title: "2048怀旧版", category: "休闲益智", emoji: "🔢", color: .indigo, description: "经典2048，像素风格", difficulty: .medium),
    ]
}

struct GameDetailView: View {
    let game: GameItem
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [game.color.opacity(0.7), game.color.opacity(0.3)],
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
                        Label(game.difficulty.rawValue, systemImage: "star.fill")
                        Spacer()
                        Label(game.category, systemImage: "tag.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

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
                        .background(game.color)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $isPlaying) {
                    GamePlayerView(game: game)
                }
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GamePlayerView: View {
    let game: GameItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            game.color.opacity(0.3).ignoresSafeArea()

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

                VStack(spacing: 12) {
                    Text(game.emoji)
                        .font(.system(size: 100))

                    Text("游戏加载中...")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Web/Unity游戏渲染区域")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Spacer()

                Text("提示：游戏需解锁完整版")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    GamesView()
        .environmentObject(AppState())
}
