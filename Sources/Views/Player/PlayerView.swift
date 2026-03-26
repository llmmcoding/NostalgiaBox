import SwiftUI
import AVKit

struct PlayerView: View {
    @State private var showFilePicker = false
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var selectedFormat: String = "万能播放"

    let supportedFormats = ["MP4", "AVI", "MP3", "FLV", "WMV", "MKV", "MOV", "WAV"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let player = player {
                    // Video Player
                    VideoPlayer(player: player)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                        .onAppear {
                            duration = player.currentItem?.duration.seconds ?? 0
                        }
                } else {
                    // Empty State
                    VStack(spacing: 16) {
                        Spacer()
                        Text("📻")
                            .font(.system(size: 80))

                        Text("复古万能播放器")
                            .font(.title2.bold())

                        Text("支持格式：\(supportedFormats.joined(separator: " / "))")
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
                if player != nil {
                    VStack(spacing: 12) {
                        Slider(value: $currentTime, in: 0...max(duration, 1))
                            .tint(Color.accentColor)

                        HStack {
                            Text(formatTime(currentTime))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(formatTime(duration))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }

                        // Format Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(supportedFormats, id: \.self) { format in
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
                        ForEach(supportedFormats, id: \.self) { format in
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
                        player = AVPlayer(url: url)
                        player?.play()
                        isPlaying = true
                    }
                case .failure(let error):
                    print("File import error: \(error)")
                }
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

#Preview {
    PlayerView()
}
