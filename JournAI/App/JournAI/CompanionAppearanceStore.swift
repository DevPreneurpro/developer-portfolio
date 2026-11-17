import Foundation
import Combine

/// Holds the user's chosen companion appearance plus the generated
/// portrait/clip URLs, persisted in UserDefaults. A single shared instance
/// so Settings, the appearance editor, and the chat screen all see the
/// same companion.
final class CompanionAppearanceStore: ObservableObject {
    static let shared = CompanionAppearanceStore()

    @Published var appearance: CompanionAppearance {
        didSet { persistAppearance() }
    }
    @Published private(set) var portraitURL: URL?
    @Published private(set) var idleClipURL: URL?
    @Published private(set) var talkingClipURL: URL?

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let appearance = "companionAppearance"
        static let portraitURL = "companionPortraitURL"
        static let idleClipURL = "companionIdleClipURL"
        static let talkingClipURL = "companionTalkingClipURL"
    }

    private init() {
        if let data = defaults.data(forKey: Keys.appearance),
           let decoded = try? JSONDecoder().decode(CompanionAppearance.self, from: data) {
            appearance = decoded
        } else {
            appearance = CompanionAppearance()
        }
        portraitURL = defaults.url(forKey: Keys.portraitURL)
        idleClipURL = defaults.url(forKey: Keys.idleClipURL)
        talkingClipURL = defaults.url(forKey: Keys.talkingClipURL)
    }

    func setPortrait(_ url: URL) {
        portraitURL = url
        defaults.set(url, forKey: Keys.portraitURL)
        // A new portrait invalidates any clips generated from the old one.
        idleClipURL = nil
        talkingClipURL = nil
        defaults.removeObject(forKey: Keys.idleClipURL)
        defaults.removeObject(forKey: Keys.talkingClipURL)
    }

    func setClips(idle: URL, talking: URL) {
        idleClipURL = idle
        talkingClipURL = talking
        defaults.set(idle, forKey: Keys.idleClipURL)
        defaults.set(talking, forKey: Keys.talkingClipURL)
    }

    private func persistAppearance() {
        guard let data = try? JSONEncoder().encode(appearance) else { return }
        defaults.set(data, forKey: Keys.appearance)
    }
}
