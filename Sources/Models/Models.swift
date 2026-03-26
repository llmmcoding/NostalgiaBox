import Foundation

struct User: Codable, Identifiable {
    let id: String
    var nickname: String
    var avatarUrl: String
    var isUnlocked: Bool
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case avatarUrl = "avatar_url"
        case isUnlocked = "is_unlocked"
        case createdAt = "created_at"
    }
}

struct Game: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let emoji: String
    let difficulty: Difficulty
    let description: String
    let thumbnailUrl: String
    let gameUrl: String
    let color: String
    let isFeatured: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, category, emoji, difficulty, description
        case thumbnailUrl = "thumbnail_url"
        case gameUrl = "game_url"
        case color
        case isFeatured = "is_featured"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
}

enum Difficulty: String, Codable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"

    var color: String {
        switch self {
        case .easy: return "#34c759"
        case .medium: return "#ff9500"
        case .hard: return "#ff3b30"
        }
    }
}

struct GameProgress: Codable {
    let id: String
    let userId: String
    let gameId: String
    let progress: [String: AnyCodable]
    let completed: Bool
    let completedAt: Date?
    let lastPlayedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case gameId = "game_id"
        case progress
        case completed
        case completedAt = "completed_at"
        case lastPlayedAt = "last_played_at"
    }
}

struct DailyContent: Codable, Identifiable {
    let id: String
    let date: String
    let title: String
    let description: String
    let emoji: String
    let year: Int

    enum CodingKeys: String, CodingKey {
        case id, date, title, description, emoji, year
    }
}

// MARK: - API Response Wrappers

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct GameListResponse: Codable {
    let games: [Game]
}

// MARK: - AnyCodable for dynamic JSON

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let arrayVal as [Any]:
            try container.encode(arrayVal.map { AnyCodable($0) })
        case let dictVal as [String: Any]:
            try container.encode(dictVal.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
