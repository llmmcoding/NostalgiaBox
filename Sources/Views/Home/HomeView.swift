import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    VStack(spacing: 8) {
                        Text("⏰ 时光机")
                            .font(.largeTitle.bold())
                        Text("带你穿越回青春")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    if !appState.isUnlocked {
                        PaywallCardView {
                            showPaywall = true
                        }
                        .padding(.horizontal)
                    }

                    // Daily Nostalgia
                    if let daily = viewModel.dailyContent {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("历史上的今天")
                                .font(.headline)
                                .padding(.horizontal)

                            HStack(spacing: 12) {
                                Text(daily.emoji)
                                    .font(.largeTitle)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(daily.title)
                                        .font(.subheadline.bold())
                                    Text("\(daily.year)年")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(daily.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }

                    // Quick Access
                    VStack(alignment: .leading, spacing: 12) {
                        Text("快速开始")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickAccessCard(
                                icon: "🎮",
                                title: "像素游戏",
                                subtitle: "魔塔·RPG·跑酷",
                                color: .purple
                            )
                            .onTapGesture {
                                // Tab switch to games - handled by parent
                            }

                            QuickAccessCard(
                                icon: "📻",
                                title: "复古播放器",
                                subtitle: "万能音视频",
                                color: .blue
                            )

                            QuickAccessCard(
                                icon: "🐣",
                                title: "电子宠物",
                                subtitle: "当年电子鸡",
                                color: .pink
                            )

                            QuickAccessCard(
                                icon: "📅",
                                title: "怀旧日历",
                                subtitle: "2000年代今天",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Nostalgia Quote
                    VStack(spacing: 8) {
                        Text(""那些年，我们没有智能手机，\n但我们有最纯粹的快乐。"")
                            .font(.system(.body, design: .serif))
                            .italic()
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("首页")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallSheetView()
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

struct QuickAccessCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(icon)
                .font(.largeTitle)

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
}
