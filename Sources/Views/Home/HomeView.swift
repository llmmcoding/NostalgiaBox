import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
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
                                // navigate to games
                            }

                            QuickAccessCard(
                                icon: "📻",
                                title: "复古播放器",
                                subtitle: "万能音视频",
                                color: .blue
                            )
                            .onTapGesture {
                                // navigate to player
                            }

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

struct PaywallCardView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🌟 解锁全部内容")
                        .font(.headline)
                    Text("一次购买，终身怀旧")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("$2.99")
                    .font(.title2.bold())
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct PaywallSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🌟")
                    .font(.system(size: 80))

                Text("解锁时光机全部内容")
                    .font(.title.bold())

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "🎮", text: "全部怀旧游戏")
                    FeatureRow(icon: "📻", text: "复古播放器")
                    FeatureRow(icon: "🐣", text: "电子宠物")
                    FeatureRow(icon: "📅", text: "怀旧日历")
                    FeatureRow(icon: "🚫", text: "无广告")
                }
                .padding()

                VStack(spacing: 8) {
                    Button("¥18 解锁全部") {
                        // IAP trigger
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Text("一次购买，永久使用")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("使用兑换码") {
                    // redeem code
                }
                .font(.subheadline)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
            Text(text)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
