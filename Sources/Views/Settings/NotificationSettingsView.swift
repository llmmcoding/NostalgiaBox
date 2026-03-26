import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @State private var isRequesting = false
    @State private var showSettingsAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("每日提醒")
                                .font(.headline)
                            Text(notificationService.isAuthorized ? "已开启" : "未开启")
                                .font(.caption)
                                .foregroundStyle(notificationService.isAuthorized ? .green : .secondary)
                        }
                        Spacer()
                        if notificationService.isAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if notificationService.isAuthorized {
                    Section("提醒类型") {
                        Toggle("每日怀旧内容", isOn: .constant(true))
                        Toggle("游戏成就解锁", isOn: .constant(true))
                        Toggle("宠物状态提醒", isOn: .constant(true))
                    }

                    Section {
                        Button("关闭所有提醒") {
                            notificationService.openSettings()
                        }
                        .foregroundStyle(.red)
                    } footer: {
                        Text("关闭提醒后，您仍可在设置中重新开启。")
                    }
                } else {
                    Section {
                        Button {
                            Task {
                                isRequesting = true
                                let granted = await notificationService.requestAuthorization()
                                isRequesting = false
                                if !granted {
                                    showSettingsAlert = true
                                }
                            }
                        } label: {
                            HStack {
                                Text("开启通知")
                                Spacer()
                                if isRequesting {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isRequesting)
                    } footer: {
                        Text("开启后，每天固定时间收到怀旧提醒。")
                    }
                }

                Section("说明") {
                    Text("我们仅发送与您使用相关的必要通知，不会发送营销类推送。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("通知设置")
            .navigationBarTitleDisplayMode(.inline)
            .alert("需要开启通知权限", isPresented: $showSettingsAlert) {
                Button("去设置") {
                    notificationService.openSettings()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("请在系统设置中开启通知权限，以便接收每日提醒。")
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
}
