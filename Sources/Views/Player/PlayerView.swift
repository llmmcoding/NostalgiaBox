import SwiftUI
import AVKit

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()
    @State private var showFilePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let player = viewModel.player {
                    // Video Player
                    VideoPlayer(player: player)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                        .onAppear {
                            viewModel.duration = player.currentItem?.duration.seconds ?? 0
                        }
                } else {
                    // Empty State
                    VStack(spacing: 16) {
                        Spacer()
                        Text("📻")
                            .font(.system(size: 80))

                        Text("复古万能播放器")
                            .font(.title2.bold())

                        Text("支持格式：\(viewModel.supportedFormats.joined(separator: " / "))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button {
                            showFilePicker = true
                        } label: {
                            Label("选择本地文件", systemImage: "folder.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Spacer()
                    }
                }

                // Playback Controls
                if viewModel.player != nil {
                    VStack(spacing: 12) {
                        Slider(value: Binding(
                            get: { viewModel.currentTime },
                            set: { viewModel.seek(to: $0) }
                        ), in: 0...max(viewModel.duration, 1))
                        .tint(Color.accentColor)

                        HStack {
                            Text(viewModel.formatTime(viewModel.currentTime))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(viewModel.formatTime(viewModel.duration))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }

                        // Play/Pause
                        HStack(spacing: 32) {
                            Button {
                                viewModel.seek(to: max(0, viewModel.currentTime - 10))
                            } label: {
                                Image(systemName: "gobackward.10")
                                    .font(.title2)
                            }

                            Button {
                                viewModel.togglePlayPause()
                            } label: {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 50))
                            }

                            Button {
                                viewModel.seek(to: min(viewModel.duration, viewModel.currentTime + 10))
                            } label: {
                                Image(systemName: "goforward.10")
                                    .font(.title2)
                            }
                        }
                        .foregroundStyle(.primary)

                        // Format Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.supportedFormats, id: \.self) { format in
                                    Text(format)
                                        .font(.caption2.weight(.medium))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                // Format Info
                List {
                    Section("支持的音视频格式") {
                        ForEach(viewModel.supportedFormats, id: \.self) { format in
                            HStack {
                                Text(format)
                                    .font(.subheadline.monospaced())
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                            }
                        }
                    } header: {
                        Text("格式兼容")
                    }

                    Section {
                        Text("本播放器仅用于播放用户本地合法授权文件。请勿用于任何侵权行为。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } header: {
                        Text("免责声明")
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("播放器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilePicker = true
                    } label: {
                        Image(systemName: "folder.fill")
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.movie, .audio, .mpeg4Movie, .avi, .mpeg4Audio, .wav, .mp3],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        // Access security scoped resource
                        _ = url.startAccessingSecurityScopedResource()
                        defer { url.stopAccessingSecurityScopedResource() }
                        viewModel.loadFile(from: url)
                    }
                case .failure(let error):
                    print("File import error: \(error)")
                }
            }
        }
    }
}

#Preview {
    PlayerView()
}
