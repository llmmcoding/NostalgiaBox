import SwiftUI

@main
struct NostalgiaBoxApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var storeKit = StoreKitService.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(storeKit)
                .environmentObject(networkMonitor)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}
