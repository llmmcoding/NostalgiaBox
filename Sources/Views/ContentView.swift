import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home
    @State private var showOnboarding = false

    enum Tab: String, CaseIterable {
        case home = "首页"
        case games = "游戏"
        case pet = "宠物"
        case player = "播放"
        case settings = "设置"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .games: return "gamecontroller.fill"
            case .pet: return "pawprint.fill"
            case .player: return "play.rectangle.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            } else {
                mainTabView
            }
        }
        .onAppear {
            showOnboarding = !appState.hasCompletedOnboarding
        }
    }

    private var mainTabView: some View {
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

            PetView()
                .tabItem {
                    Label(Tab.pet.rawValue, systemImage: Tab.pet.icon)
                }
                .tag(Tab.pet)

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
        .environmentObject(AppState.shared)
}
