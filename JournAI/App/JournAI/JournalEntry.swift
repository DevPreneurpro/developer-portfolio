import Foundation
import SwiftData

enum Mood: Int, CaseIterable, Identifiable, Codable {
    case veryLow = 0
    case low
    case neutral
    case good
    case great

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .veryLow: return "Struggling"
        case .low: return "Low"
        case .neutral: return "Reflective"
        case .good: return "Good"
        case .great: return "Great"
        }
    }
}

@Model
final class JournalEntry {
    var date: Date
    var moodRawValue: Int
    var text: String
    var aiReflection: String
    var tags: [String]

    init(date: Date = .now, mood: Mood, text: String, aiReflection: String, tags: [String] = []) {
        self.date = date
        self.moodRawValue = mood.rawValue
        self.text = text
        self.aiReflection = aiReflection
        self.tags = tags
    }

    var mood: Mood {
        get { Mood(rawValue: moodRawValue) ?? .neutral }
        set { moodRawValue = newValue.rawValue }
    }
}
