import SwiftUI

final class AppState: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var colorScheme: ColorScheme? = nil
    @Published var hasCompletedOnboarding: Bool = false

    init() {
        isUnlocked = UserDefaults.standard.bool(forKey: "isUnlocked")
        if let schemeValue = UserDefaults.standard.string(forKey: "colorScheme") {
            colorScheme = schemeValue == "dark" ? .dark : (schemeValue == "light" ? .light : nil)
        }
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func setColorScheme(_ scheme: ColorScheme?) {
        colorScheme = scheme
        if let scheme = scheme {
            UserDefaults.standard.set(scheme == .dark ? "dark" : "light", forKey: "colorScheme")
        } else {
            UserDefaults.standard.removeObject(forKey: "colorScheme")
        }
    }

    func unlock() {
        isUnlocked = true
        UserDefaults.standard.set(true, forKey: "isUnlocked")
    }
}
