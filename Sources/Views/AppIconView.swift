import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            Color(hex: "FF6B6B")
                .ignoresSafeArea()

            VStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)

                Image(systemName: "hourglass")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.8))
            }

            // Pixel-style corner accents
            VStack {
                HStack {
                    pixelAccent()
                    Spacer()
                    pixelAccent()
                        .scaleEffect(x: -1, y: 1)
                }
                Spacer()
                HStack {
                    pixelAccent()
                        .scaleEffect(x: 1, y: -1)
                    Spacer()
                    pixelAccent()
                        .scaleEffect(x: -1, y: -1)
                }
            }
            .padding(24)
        }
    }

    private func pixelAccent() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { col in
                        Rectangle()
                            .fill(Color.white.opacity(row == 1 && col == 1 ? 1.0 : 0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    AppIconView()
}