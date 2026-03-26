import Foundation

// MARK: - Firebase Analytics Service
// 使用说明：
// 1. 在 Firebase Console 创建项目：https://console.firebase.google.com
// 2. 下载 GoogleService-Info.plist 放入 App/ 目录
// 3. 在 Xcode 中配置 Firebase（pod 'Firebase/Analytics' 或 SPM）
// 4. 将下方 kFirebaseEnabled 改为 true

@MainActor
final class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()

    private let kFirebaseEnabled = false  // TODO: 开通 Firebase 后改为 true

    private init() {}

    // MARK: - Events

    func logEvent(_ name: String, params: [String: Any]? = nil) {
        guard kFirebaseEnabled else { return }
        // Firebase.Analytics.logEvent(name, parameters: params)
    }

    // MARK: - Screen Views

    func logScreenView(screenName: String) {
        logEvent("screen_view", params: ["screen_name": screenName])
    }

    // MARK: - User Properties

    func setUserProperty(name: String, value: String?) {
        guard kFirebaseEnabled else { return }
        // Firebase.Analytics.setUserProperty(value, forName: name)
    }

    // MARK: - Specific Events

    func logAppOpen() {
        logEvent("app_open")
    }

    func logGameStart(gameId: String, gameName: String) {
        logEvent("game_start", params: [
            "game_id": gameId,
            "game_name": gameName
        ])
    }

    func logGameComplete(gameId: String, gameName: String, duration: Int) {
        logEvent("game_complete", params: [
            "game_id": gameId,
            "game_name": gameName,
            "duration_seconds": duration
        ])
    }

    func logPurchase(productId: String, amount: Double) {
        logEvent("purchase", params: [
            "product_id": productId,
            "amount": amount,
            "currency": "CNY"
        ])
    }

    func logSignIn(method: String) {
        logEvent("sign_in", params: ["method": method])
    }

    func logOnboardingComplete() {
        logEvent("onboarding_complete")
    }

    func logPetAction(action: String) {
        logEvent("pet_action", params: ["action": action])
    }

    func logDailyContentView(date: String) {
        logEvent("daily_content_view", params: ["date": date])
    }

    func logPaywallShown() {
        logEvent("paywall_shown")
    }

    func logPaywallDismiss() {
        logEvent("paywall_dismiss")
    }

    func logUnlock() {
        logEvent("unlock")
    }
}
