import Foundation

/// Talks to the shared Express backend (JournAI/web/server) for real Claude
/// replies and reflections — the same backend and the same /api/companion/*
/// routes the web app uses. Falls back to MockAICompanionService when the
/// backend can't be reached or has no Anthropic key configured yet, so the
/// app still works standalone.
struct BackendCompanionService: AICompanionService {
    private let mock = MockAICompanionService()

    func opener() -> String {
        mock.opener()
    }

    func reply(to conversation: [ChatMessage]) async -> String {
        struct Message: Encodable { let role: String; let text: String }
        struct RequestBody: Encodable {
            let messages: [Message]
            let companionName: String
            let personality: String
        }
        struct ResponseBody: Decodable { let text: String }

        let defaults = UserDefaults.standard
        let body = RequestBody(
            messages: conversation.map { Message(role: $0.role == .ai ? "ai" : "user", text: $0.text) },
            companionName: defaults.string(forKey: "companionName") ?? "Sage",
            personality: defaults.string(forKey: "companionPersonality") ?? "Calm & Curious"
        )

        do {
            let data = try await Self.post("/api/companion/reply", body: body)
            let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
            return decoded.text
        } catch {
            print("Falling back to offline companion reply: \(error)")
            return await mock.reply(to: conversation)
        }
    }

    func reflect(on entryText: String) async -> (reflection: String, tags: [String]) {
        struct RequestBody: Encodable { let text: String }
        struct ResponseBody: Decodable { let reflection: String; let tags: [String] }

        do {
            let data = try await Self.post("/api/companion/reflect", body: RequestBody(text: entryText))
            let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
            return (decoded.reflection, decoded.tags)
        } catch {
            print("Falling back to offline reflection: \(error)")
            return await mock.reflect(on: entryText)
        }
    }

    private static func post<Body: Encodable>(_ path: String, body: Body, timeout: TimeInterval = 30) async throws -> Data {
        var request = URLRequest(url: BackendConfig.baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
