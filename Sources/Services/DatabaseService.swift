import Foundation
import SQLite3

final class DatabaseService {
    static let shared = DatabaseService()

    private var db: OpaquePointer?
    private let dbPath: String

    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dbPath = documentsPath.appendingPathComponent("nostalgiabox.sqlite3").path
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Failed to open database")
        }
    }

    private func createTables() {
        let createGamesTable = """
        CREATE TABLE IF NOT EXISTS games (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            emoji TEXT NOT NULL,
            difficulty TEXT NOT NULL,
            description TEXT DEFAULT '',
            thumbnail_url TEXT DEFAULT '',
            game_url TEXT DEFAULT '',
            color TEXT DEFAULT '#FF6B6B',
            is_featured INTEGER DEFAULT 0,
            cached_at TEXT DEFAULT (datetime('now'))
        );
        """

        let createProgressTable = """
        CREATE TABLE IF NOT EXISTS game_progress (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            game_id TEXT NOT NULL,
            progress TEXT DEFAULT '{}',
            completed INTEGER DEFAULT 0,
            completed_at TEXT,
            last_played_at TEXT DEFAULT (datetime('now'))
        );
        """

        let createDailyTable = """
        CREATE TABLE IF NOT EXISTS daily_content (
            id TEXT PRIMARY KEY,
            date TEXT UNIQUE NOT NULL,
            title TEXT NOT NULL,
            description TEXT DEFAULT '',
            emoji TEXT DEFAULT '📅',
            year INTEGER DEFAULT 0,
            cached_at TEXT DEFAULT (datetime('now'))
        );
        """

        execute(sql: createGamesTable)
        execute(sql: createProgressTable)
        execute(sql: createDailyTable)
    }

    private func execute(sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    // MARK: - Games

    func cacheGames(_ games: [Game]) {
        let sql = "INSERT OR REPLACE INTO games (id, title, category, emoji, difficulty, description, thumbnail_url, game_url, color, is_featured) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?

        for game in games {
            if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (game.id as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (game.title as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (game.category as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 4, (game.emoji as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 5, (game.difficulty.rawValue as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 6, (game.description as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 7, (game.thumbnailUrl as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 8, (game.gameUrl as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 9, (game.color as NSString).utf8String, -1, nil)
                sqlite3_bind_int(statement, 10, game.isFeatured ? 1 : 0)
                sqlite3_step(statement)
            }
            sqlite3_finalize(statement)
        }
    }

    func getCachedGames() -> [Game] {
        var games: [Game] = []
        let sql = "SELECT * FROM games ORDER BY is_featured DESC, title ASC"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let game = gameFromStatement(statement) {
                    games.append(game)
                }
            }
        }
        sqlite3_finalize(statement)
        return games
    }

    private func gameFromStatement(_ stmt: OpaquePointer?) -> Game? {
        guard let stmt = stmt else { return nil }

        let id = String(cString: sqlite3_column_text(stmt, 0))
        let title = String(cString: sqlite3_column_text(stmt, 1))
        let category = String(cString: sqlite3_column_text(stmt, 2))
        let emoji = String(cString: sqlite3_column_text(stmt, 3))
        let difficultyStr = String(cString: sqlite3_column_text(stmt, 4))
        let difficulty = Difficulty(rawValue: difficultyStr) ?? .medium
        let description = String(cString: sqlite3_column_text(stmt, 5))
        let thumbnailUrl = String(cString: sqlite3_column_text(stmt, 6))
        let gameUrl = String(cString: sqlite3_column_text(stmt, 7))
        let color = String(cString: sqlite3_column_text(stmt, 8))
        let isFeatured = sqlite3_column_int(stmt, 9) == 1

        return Game(id: id, title: title, category: category, emoji: emoji,
                    difficulty: difficulty, description: description,
                    thumbnailUrl: thumbnailUrl, gameUrl: gameUrl,
                    color: color, isFeatured: isFeatured)
    }

    // MARK: - Progress

    func saveProgress(_ progress: GameProgress) {
        let sql = "INSERT OR REPLACE INTO game_progress (id, user_id, game_id, progress, completed, completed_at, last_played_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (progress.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (progress.userId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (progress.gameId as NSString).utf8String, -1, nil)
            if let progressJSON = try? JSONSerialization.data(withJSONObject: progress.progress.mapValues { $0.value }),
               let progressStr = String(data: progressJSON, encoding: .utf8) {
                sqlite3_bind_text(statement, 4, (progressStr as NSString).utf8String, -1, nil)
            }
            sqlite3_bind_int(statement, 5, progress.completed ? 1 : 0)
            if let completedAt = progress.completedAt {
                sqlite3_bind_text(statement, 6, (ISO8601DateFormatter().string(from: completedAt) as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 6)
            }
            if let lastPlayed = progress.lastPlayedAt {
                sqlite3_bind_text(statement, 7, (ISO8601DateFormatter().string(from: lastPlayed) as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 7)
            }
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func getProgress(for gameId: String) -> GameProgress? {
        let sql = "SELECT * FROM game_progress WHERE game_id = ?"
        var statement: OpaquePointer?
        var progress: GameProgress?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (gameId as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                progress = progressFromStatement(statement)
            }
        }
        sqlite3_finalize(statement)
        return progress
    }

    private func progressFromStatement(_ stmt: OpaquePointer?) -> GameProgress? {
        guard let stmt = stmt else { return nil }

        let id = String(cString: sqlite3_column_text(stmt, 0))
        let userId = String(cString: sqlite3_column_text(stmt, 1))
        let gameId = String(cString: sqlite3_column_text(stmt, 2))
        let progressStr = String(cString: sqlite3_column_text(stmt, 3))
        var progressDict: [String: Any] = [:]
        if let data = progressStr.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            progressDict = dict
        }
        let completed = sqlite3_column_int(stmt, 4) == 1
        let completedAtStr = sqlite3_column_text(stmt, 5)
        let completedAt = completedAtStr.flatMap { ISO8601DateFormatter().date(from: String(cString: $0)) }
        let lastPlayedStr = sqlite3_column_text(stmt, 6)
        let lastPlayed = lastPlayedStr.flatMap { ISO8601DateFormatter().date(from: String(cString: $0)) }

        return GameProgress(id: id, userId: userId, gameId: gameId,
                           progress: progressDict.mapValues { AnyCodable($0) },
                           completed: completed, completedAt: completedAt, lastPlayedAt: lastPlayed)
    }

    // MARK: - Daily Content

    func cacheDailyContent(_ content: DailyContent) {
        let sql = "INSERT OR REPLACE INTO daily_content (id, date, title, description, emoji, year) VALUES (?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (content.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (content.date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (content.title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (content.description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (content.emoji as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 6, Int32(content.year))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func getCachedDailyContent(for date: String) -> DailyContent? {
        let sql = "SELECT * FROM daily_content WHERE date = ?"
        var statement: OpaquePointer?
        var content: DailyContent?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (date as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let date = String(cString: sqlite3_column_text(stmt, 1))
                let title = String(cString: sqlite3_column_text(stmt, 2))
                let description = String(cString: sqlite3_column_text(stmt, 3))
                let emoji = String(cString: sqlite3_column_text(stmt, 4))
                let year = Int(sqlite3_column_int(stmt, 5))
                content = DailyContent(id: id, date: date, title: title, description: description, emoji: emoji, year: year)
            }
        }
        sqlite3_finalize(statement)
        return content
    }
}
