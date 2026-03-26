import SwiftUI

struct PetView: View {
    @StateObject private var viewModel = PetViewModel()
    @State private var showNameEditor = false
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Pet Display
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: viewModel.healthColor).opacity(0.3), Color(hex: viewModel.healthColor).opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 200, height: 200)

                    VStack(spacing: 8) {
                        Text(viewModel.pet.type.emoji)
                            .font(.system(size: 80))
                            .opacity(viewModel.isAlive ? 1 : 0.3)

                        Text(viewModel.isAlive ? viewModel.pet.mood.emoji : "💀")
                            .font(.title)
                    }
                }
                .onTapGesture {
                    if viewModel.isAlive {
                        viewModel.play()
                    }
                }

                // Name
                Button {
                    newName = viewModel.pet.name
                    showNameEditor = true
                } label: {
                    HStack {
                        Text(viewModel.pet.name)
                            .font(.title2.bold())
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                // Stats
                VStack(spacing: 12) {
                    StatBar(label: "饱腹感", value: viewModel.pet.stats.hunger, color: "#ff9500")
                    StatBar(label: "快乐", value: viewModel.pet.stats.happiness, color: "#fbbf24")
                    StatBar(label: "精力", value: viewModel.pet.stats.energy, color: "#34d399")
                }
                .padding(.horizontal)

                // Mood text
                Text("\(viewModel.pet.mood.emoji) \(viewModel.pet.mood.rawValue) — \(viewModel.statText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Action Buttons
                HStack(spacing: 20) {
                    ActionButton(icon: "🍞", label: "喂食", color: "#ff9500") {
                        viewModel.feed()
                    }

                    ActionButton(icon: "🎮", label: "玩耍", color: "#a78bfa") {
                        viewModel.play()
                    }

                    ActionButton(icon: "😴", label: "睡觉", color: "#60a5fa") {
                        viewModel.sleep()
                    }
                }
                .padding(.bottom, 32)
            }
            .padding()
            .navigationTitle("电子宠物")
            .navigationBarTitleDisplayMode(.inline)
            .alert("宠物离世了...", isPresented: $viewModel.showDeathAlert) {
                Button("重新领养") {
                    viewModel.revive()
                }
            } message: {
                Text("你的\(viewModel.pet.name)离开了。别难过，重新领养一只吧。")
            }
            .sheet(isPresented: $showNameEditor) {
                NavigationStack {
                    Form {
                        TextField("名字", text: $newName)
                    }
                    .navigationTitle("修改名字")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") { showNameEditor = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                viewModel.pet.name = newName.isEmpty ? viewModel.pet.type.defaultName : newName
                                showNameEditor = false
                            }
                        }
                    }
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}

struct StatBar: View {
    let label: String
    let value: Double
    let color: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: color))
                        .frame(width: geo.size.width * value, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: color).opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Text(icon)
                            .font(.title)
                    }
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PetView()
}
