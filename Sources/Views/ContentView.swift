import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home = "首页"
        case games = "游戏"
        case player = "播放器"
        case settings = "设置"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .games: return "gamecontroller.fill"
            case .player: return "play.rectangle.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)

            GamesView()
                .tabItem {
                    Label(Tab.games.rawValue, systemImage: Tab.games.icon)
                }
                .tag(Tab.games)

            PlayerView()
                .tabItem {
                    Label(Tab.player.rawValue, systemImage: Tab.player.icon)
                }
                .tag(Tab.player)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.accentColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
