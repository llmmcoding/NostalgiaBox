import SwiftUI
import AuthenticationServices
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeKit: StoreKitService
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showContact = false
    @State private var showRestore = false
    @State private var showPaywall = false
    @State private var showNotificationSettings = false
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    if let user = appState.currentUser {
                        HStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Text(String(user.nickname.prefix(1)).uppercased())
                                        .font(.title2.bold())
                                        .foregroundStyle(Color.accentColor)
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.nickname.isEmpty ? "用户" : user.nickname)
                                    .font(.headline)
                                Text("Apple ID 已登录")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    } else {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.email]
                        } onCompletion: { result in
                            handleSignInWithApple(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 44)
                        .disabled(isSigningIn)
                        .overlay {
                            if isSigningIn {
                                ProgressView()
                            }
                        }
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    if appState.isUnlocked {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Text("已解锁完整版")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("✓")
                                .foregroundStyle(.green)
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "lock.open.fill")
                                    .foregroundStyle(.orange)
                                Text("解锁完整版")
                                Spacer()
                                Text("¥18")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("账号")
                }

                // Appearance
                Section("外观") {
                    Picker("主题", selection: Binding(
                        get: { appState.colorScheme ?? .unspecified },
                        set: { appState.setColorScheme($0 == .unspecified ? nil : $0) }
                    )) {
                        Text("跟随系统").tag(ColorScheme?.none)
                        Text("浅色").tag(ColorScheme?.some(.light))
                        Text("深色").tag(ColorScheme?.some(.dark))
                    }
                }

                // Support
                Section("支持") {
                    Button {
                        showNotificationSettings = true
                    } label: {
                        HStack {
                            Text("通知设置")
                            Spacer()
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showContact = true
                    } label: {
                        HStack {
                            Text("联系客服 / 反馈")
                            Spacer()
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        Task {
                            await storeKit.restorePurchases()
                        }
                        showRestore = true
                    } label: {
                        HStack {
                            Text("恢复购买")
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.blue)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // About
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://nostalgiabox.app")!) {
                        HStack {
                            Text("官网")
                            Spacer()
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // Rating
                Section {
                    Button {
                        SKStoreReviewController.requestReview()
                    } label: {
                        HStack {
                            Text("给我们评分 🌟")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showContact) {
                ContactView()
            }
            .alert("恢复购买", isPresented: $showRestore) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(storeKit.isUnlocked ? "已恢复购买，完整版已解锁！" : "未找到购买记录，如有疑问请联系客服。")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheetView()
            }
            .sheet(isPresented: $showNotificationSettings) {
                NotificationSettingsView()
            }
        }
    }

    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        isSigningIn = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let identityToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                let user = credential.user

                Task {
                    do {
                        let response = try await APIService.shared.appleAuth(
                            identityToken: identityToken,
                            authorizationCode: authorizationCode,
                            user: user
                        )
                        await MainActor.run {
                            appState.updateFromUser(response.user)
                            isSigningIn = false
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "登录失败：\(error.localizedDescription)"
                            isSigningIn = false
                        }
                    }
                }
            }
        case .failure(let error):
            errorMessage = "登录失败：\(error.localizedDescription)"
            isSigningIn = false
        }
    }
}
