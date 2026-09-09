import Foundation

struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable { case ai, user }
    let id = UUID()
    let role: Role
    let text: String
}

/// Talks to the journaling companion. `MockAICompanionService` is a stand-in
/// with canned, rotating responses — swap in a real implementation here once
/// there's a model/backend to call.
protocol AICompanionService {
    func opener() -> String
    func reply(to conversation: [ChatMessage]) async -> String
    func reflect(on entryText: String) async -> (reflection: String, tags: [String])
}

struct MockAICompanionService: AICompanionService {
    private let openers = [
        "Hey — I'm here. What's on your mind tonight?",
        "Good to see you. How are you actually doing today, underneath the surface?",
        "I'm listening. Start wherever feels right."
    ]

    private let followUps = [
        "That sounds heavy to carry. When you say that, is it more about what happened, or how it's sitting with you now?",
        "Thank you for putting that into words. What do you think you need most right now?",
        "I hear you. Was there a moment today, even a small one, that felt different from that?",
        "That makes sense. What would it look like to be a little kinder to yourself about this tonight?",
        "I'm glad you're telling me this. Want to sit with that thought a bit longer, or move on?"
    ]

    func opener() -> String {
        openers.randomElement() ?? openers[0]
    }

    func reply(to conversation: [ChatMessage]) async -> String {
        try? await Task.sleep(nanoseconds: 700_000_000)
        return followUps.randomElement() ?? followUps[0]
    }

    func reflect(on entryText: String) async -> (reflection: String, tags: [String]) {
        try? await Task.sleep(nanoseconds: 500_000_000)

        let lower = entryText.lowercased()
        let keywordTags: [(String, String)] = [
            ("work", "Work Stress"), ("tired", "Fatigue"), ("thank", "Gratitude"),
            ("grateful", "Gratitude"), ("friend", "Connection"), ("family", "Family"),
            ("anxious", "Anxiety"), ("sleep", "Sleep"), ("happy", "Joy"), ("love", "Connection")
        ]
        var tags: [String] = []
        for (keyword, tag) in keywordTags where lower.contains(keyword) {
            if !tags.contains(tag) { tags.append(tag) }
        }
        if tags.isEmpty { tags = ["Reflection"] }

        let reflection = "You're carrying a lot right now, but you also put it into words — that's worth coming back to."
        return (reflection, Array(tags.prefix(3)))
    }
}
