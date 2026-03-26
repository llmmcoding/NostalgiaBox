import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showContact = false
    @State private var showRestore = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email]
                    } onCompletion: { _ in
                        // handle
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 44)

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
                                Text("$2.99")
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

                // Legal
                Section("法律") {
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        HStack {
                            Text("隐私政策")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showTermsOfService = true
                    } label: {
                        HStack {
                            Text("用户协议")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // Support
                Section("支持") {
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
                Button("取消", role: .cancel) {}
                Button("恢复") {
                    // restore IAP
                }
            } message: {
                Text("如已完成购买但未解锁，请点击恢复。")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheetView()
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("隐私政策")
                        .font(.title.bold())
                    Text("最后更新：2026年3月25日")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("""
                    **1. 信息收集**
                    本应用不会收集、存储或分享您的个人身份信息。

                    **2. Apple登录**
                    我们使用Sign in with Apple来创建账号，只会读取您的邮箱（如果选择分享）。

                    **3. 本地存储**
                    所有用户数据（如游戏存档）仅存储在您的设备本地。

                    **4. 第三方服务**
                    我们使用Firebase Crashlytics来监控应用崩溃情况，以提升应用质量。

                    **5. 音视频文件**
                    复古播放器仅读取您主动选择的本地文件，不会自动上传或分享。

                    **6. 联系我们**
                    如有隐私问题，请通过设置页联系我们。
                    """)
                    .font(.body)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("用户协议")
                        .font(.title.bold())
                    Text("最后更新：2026年3月25日")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("""
                    **1. 服务描述**
                    时光机是一款面向80/90后用户的怀旧复刻类App，提供游戏、播放器等休闲功能。

                    **2. 使用规范**
                    您承诺仅将本应用用于合法目的，不进行任何反向工程、破解或侵权行为。

                    **3. 知识产权**
                    应用内所有游戏和内容均为自有版权或已获合法授权，禁止转载或商业使用。

                    **4. 付费服务**
                    付费内容为一次性买断制，购买后不可退款，但可在同一Apple ID下恢复。

                    **5. 免责声明**
                    本应用按"现状"提供，我们不对游戏内容的完整性、适用性做任何保证。

                    **6. 联系我们**
                    如有疑问，请通过设置页联系客服。
                    """)
                    .font(.body)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var feedbackType = "功能反馈"

    let feedbackTypes = ["功能反馈", "Bug报告", "购买问题", "合作洽谈", "其他"]

    var body: some View {
        NavigationStack {
            Form {
                Section("反馈类型") {
                    Picker("类型", selection: $feedbackType) {
                        ForEach(feedbackTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("反馈内容") {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 120)
                }

                Section {
                    Button("提交反馈") {
                        // submit feedback
                        dismiss()
                    }
                    .disabled(feedbackText.isEmpty)
                }
            }
            .navigationTitle("联系客服")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
