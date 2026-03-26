import SwiftUI

struct PaywallSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeKit: StoreKitService
    @State private var isPurchasing = false
    @State private var errorMessage: String?

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
                    if storeKit.products.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Button {
                            Task {
                                await purchase()
                            }
                        } label: {
                            if isPurchasing {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("¥18 解锁全部")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(isPurchasing || storeKit.products.isEmpty)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Text("一次购买，永久使用")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("使用兑换码") {
                    // redeem code
                }
                .font(.subheadline)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
            .task {
                await storeKit.loadProducts()
            }
        }
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        do {
            let transaction = try await storeKit.purchase()
            if transaction != nil {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
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
