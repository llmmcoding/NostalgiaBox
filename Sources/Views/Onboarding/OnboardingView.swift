import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    var body: some View {
        TabView {
            OnboardingPage(
                emoji: "⏰",
                title: "欢迎来到时光机",
                subtitle: "带你穿越回青春",
                description: "那些年，我们没有智能手机，但有最纯粹的快乐。\n现在，让时光机带你重温那些经典。"
            )

            OnboardingPage(
                emoji: "🎮",
                title: "经典游戏",
                subtitle: "魔塔·RPG·跑酷",
                description: "重温那些年我们一起玩过的游戏。\n像素勇者、魔塔大陆、2048...每一个都是回忆。"
            )

            OnboardingPage(
                emoji: "📻",
                title: "复古播放器",
                subtitle: "万能音视频播放",
                description: "支持所有主流格式。\n那些年的MV、动漫、老电影，随时随地播放。"
            )

            OnboardingPage(
                emoji: "🚀",
                title: "准备好了吗？",
                subtitle: "一起穿越吧",
                description: "点击开始，开启你的时光之旅。",
                isLastPage: true,
                onContinue: {
                    appState.setOnboardingCompleted()
                    isPresented = false
                }
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let subtitle: String
    let description: String
    var isLastPage: Bool = false
    var onContinue: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(emoji)
                .font(.system(size: 100))

            VStack(spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())

                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()

            if isLastPage, let action = onContinue {
                Button {
                    action()
                } label: {
                    Text("开始探索")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(AppState.shared)
}
