import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case unauthorized
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的 URL"
        case .networkError(let err): return "网络错误: \(err.localizedDescription)"
        case .invalidResponse: return "无效的服务器响应"
        case .httpError(let code): return "HTTP 错误: \(code)"
        case .decodingError(let err): return "数据解析错误: \(err.localizedDescription)"
        case .unauthorized: return "未授权，请重新登录"
        case .serverError(let msg): return "服务器错误: \(msg)"
        }
    }
}

actor APIService {
    static let shared = APIService()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        // TODO: 替换为实际后端地址
        self.baseURL = "http://localhost:3001"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatters = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd"
            ]
            for format in formatters {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }

        self.encoder = JSONEncoder()
    }

    // MARK: - Token Management

    private var authToken: String? {
        get { KeychainService.shared.get(key: "auth_token") }
        set {
            if let token = newValue {
                KeychainService.shared.save(key: "auth_token", value: token)
            } else {
                KeychainService.shared.delete(key: "auth_token")
            }
        }
    }

    func setToken(_ token: String) {
        authToken = token
    }

    func clearToken() {
        authToken = nil
    }

    var isLoggedIn: Bool {
        authToken != nil
    }

    // MARK: - Generic Request

    private func request<T: Decodable>(
        method: String,
        path: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Auth

    func appleAuth(identityToken: String, authorizationCode: String, user: String?) async throws -> AuthResponse {
        let body: [String: Any] = [
            "identityToken": identityToken,
            "authorizationCode": authorizationCode,
            "user": user ?? ""
        ]
        let response: AuthResponse = try await request(method: "POST", path: "/auth/apple", body: body)
        setToken(response.token)
        return response
    }

    // MARK: - User

    func getProfile() async throws -> User {
        try await request(method: "GET", path: "/user/profile", requiresAuth: true)
    }

    func updateProfile(nickname: String) async throws -> User {
        try await request(method: "PUT", path: "/user/profile", body: ["nickname": nickname], requiresAuth: true)
    }

    func getProgress() async throws -> [GameProgress] {
        try await request(method: "GET", path: "/user/progress", requiresAuth: true)
    }

    func saveProgress(gameId: String, progress: [String: Any], completed: Bool) async throws -> GameProgress {
        let body: [String: Any] = [
            "gameId": gameId,
            "progress": progress,
            "completed": completed
        ]
        return try await request(method: "POST", path: "/user/progress", body: body, requiresAuth: true)
    }

    // MARK: - Games

    func getGames() async throws -> [Game] {
        let response: GameListResponse = try await request(method: "GET", path: "/games")
        return response.games
    }

    func getGame(id: String) async throws -> Game {
        try await request(method: "GET", path: "/games/\(id)")
    }

    func getFeaturedGames() async throws -> [Game] {
        try await request(method: "GET", path: "/games/featured")
    }

    // MARK: - IAP

    func verifyReceipt(receiptData: String) async throws -> User {
        try await request(method: "POST", path: "/iap/verify", body: ["receiptData": receiptData], requiresAuth: true)
    }

    // MARK: - Daily Content

    func getDailyContent(date: String? = nil) async throws -> DailyContent {
        let path = date.map { "/content/daily?date=\($0)" } ?? "/content/daily"
        return try await request(method: "GET", path: path)
    }
}
