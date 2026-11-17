import Foundation

/// Calls the backend's Higgsfield-backed avatar endpoints: one portrait
/// image generated from the chosen appearance traits, then (optionally,
/// since it costs meaningfully more) a couple of short looping video clips
/// generated once from that portrait and reused for every chat session —
/// never regenerated per message.
enum CompanionAvatarService {
    struct ServiceError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    static func generatePortrait(for appearance: CompanionAppearance) async throws -> URL {
        struct Traits: Encodable {
            let gender, age, ethnicity, hair, hairColor, eyeColor, build, style, accessory: String
        }
        struct RequestBody: Encodable { let traits: Traits }
        struct ResponseBody: Decodable { let imageUrl: String }

        let traits = Traits(
            gender: CompanionAppearance.label(for: appearance.gender),
            age: CompanionAppearance.label(for: appearance.age),
            ethnicity: CompanionAppearance.label(for: appearance.ethnicity),
            hair: CompanionAppearance.label(for: appearance.hair),
            hairColor: CompanionAppearance.label(for: appearance.hairColor),
            eyeColor: CompanionAppearance.label(for: appearance.eyeColor),
            build: CompanionAppearance.label(for: appearance.build),
            style: appearance.style,
            accessory: appearance.accessory
        )

        let data = try await post("/api/companion/avatar/portrait", body: RequestBody(traits: traits), timeout: 60)
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let url = URL(string: decoded.imageUrl) else { throw ServiceError(message: "Backend returned an invalid portrait URL.") }
        return url
    }

    static func generateClips(portraitURL: URL) async throws -> (idle: URL, talking: URL) {
        struct RequestBody: Encodable { let imageUrl: String }
        struct ResponseBody: Decodable { let idleUrl: String; let talkingUrl: String }

        // Video generation is slow (the server polls Higgsfield for up to 3
        // minutes), so this request needs a long client-side timeout too.
        let data = try await post("/api/companion/avatar/clips", body: RequestBody(imageUrl: portraitURL.absoluteString), timeout: 200)
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let idle = URL(string: decoded.idleUrl), let talking = URL(string: decoded.talkingUrl) else {
            throw ServiceError(message: "Backend returned invalid clip URLs.")
        }
        return (idle, talking)
    }

    private static func post<Body: Encodable>(_ path: String, body: Body, timeout: TimeInterval) async throws -> Data {
        var request = URLRequest(url: BackendConfig.baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ServiceError(message: "No response from the backend. Is it running?")
        }
        guard (200..<300).contains(http.statusCode) else {
            if let decoded = try? JSONDecoder().decode([String: String].self, from: data), let message = decoded["error"] {
                throw ServiceError(message: message)
            }
            throw ServiceError(message: "Request failed (\(http.statusCode)).")
        }
        return data
    }
}
