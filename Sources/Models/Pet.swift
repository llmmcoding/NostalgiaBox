import Foundation

struct Pet: Codable, Identifiable {
    let id: String
    var name: String
    var type: PetType
    var stats: PetStats
    var lastFedAt: Date?
    var lastPlayedAt: Date?
    var lastSleptAt: Date?
    var mood: Mood

    var overallHealth: Double {
        (stats.hunger + stats.happiness + stats.energy) / 3.0
    }

    enum PetType: String, Codable, CaseIterable {
        case chick = "小鸡"
        case dog = "小狗"
        case cat = "小猫"

        var emoji: String {
            switch self {
            case .chick: return "🐣"
            case .dog: return "🐶"
            case .cat: return "🐱"
            }
        }

        var defaultName: String {
            switch self {
            case .chick: return "小黄"
            case .dog: return "旺财"
            case .cat: return "咪咪"
            }
        }
    }

    enum Mood: String, Codable {
        case happy = "开心"
        case normal = "普通"
        case sad = "难过"
        case hungry = "饿了"
        case sleepy = "困了"

        var emoji: String {
            switch self {
            case .happy: return "😊"
            case .normal: return "😐"
            case .sad: return "😢"
            case .hungry: return "🤤"
            case .sleepy: return "😴"
            }
        }

        static func from(health: Double, hunger: Double, energy: Double) -> Mood {
            if health < 0.3 { return .sad }
            if hunger < 0.3 { return .hungry }
            if energy < 0.3 { return .sleepy }
            if health > 0.7 { return .happy }
            return .normal
        }
    }
}

struct PetStats: Codable {
    var hunger: Double      // 0-1, 0 = starving
    var happiness: Double   // 0-1, 0 = sad
    var energy: Double      // 0-1, 0 = exhausted

    static var initial: PetStats {
        PetStats(hunger: 0.7, happiness: 0.7, energy: 0.8)
    }
}

extension Pet {
    static var defaultPet: Pet {
        Pet(
            id: UUID().uuidString,
            name: "小黄",
            type: .chick,
            stats: .initial,
            lastFedAt: Date(),
            lastPlayedAt: Date(),
            lastSleptAt: Date(),
            mood: .normal
        )
    }
}
