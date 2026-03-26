import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published private(set) var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            isAuthorized = granted
            if granted {
                await registerForRemoteNotifications()
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Remote Notifications

    private func registerForRemoteNotifications() async {
        #if !targetEnvironment(simulator)
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            UIApplication.shared.registerForRemoteNotifications()
            continuation.resume()
        }
        #endif
    }

    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        // TODO: Send token to backend for push notifications
        // APIService.shared.registerPushToken(token)
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    // MARK: - Local Notifications

    func scheduleDailyReminder(at hour: Int = 9, minute: Int: 0) async {
        // Cancel existing daily reminders first
        await cancelDailyReminders()

        let content = UNMutableNotificationContent()
        content.title = "⏰ 时光机"
        content.body = "你又活了一天！来看看今天有什么新鲜的？"
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("Failed to schedule daily reminder: \(error)")
        }
    }

    func cancelDailyReminders() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }

    func scheduleGameAchievement(gameName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "🎮 游戏成就解锁"
        content.body = "你在 \(gameName) 中获得了新成就！快来看看吧！"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func schedulePetNotification(message: String) async {
        let content = UNMutableNotificationContent()
        content.title = "🐣 你的电子宠物"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "pet-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Badge

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Permission Check in Settings

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
