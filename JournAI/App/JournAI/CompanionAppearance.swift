import Foundation

/// What the user's companion looks like. Trait IDs mirror a real trait
/// vocabulary (gender, build, hair, ethnicity, age, eye color, style...) so
/// the backend can turn a selection into a descriptive image-generation
/// prompt. Persisted as JSON by CompanionAppearanceStore.
struct CompanionAppearance: Codable, Equatable {
    var gender = "female"
    var age = "adult"
    var ethnicity = "european"
    var hair = "hair_long"
    var hairColor = "hc_darkbrown"
    var eyeColor = "eye_brown"
    var build = "body_slim"
    var style = "casual"
    var accessory = "none"

    static let genders = ["female", "male", "non_binary"]
    static let ages = ["adult", "mature", "senior"]
    static let ethnicities = ["african", "east_asian", "european", "indian", "middle_eastern", "latin_american"]
    static let hairStyles = ["hair_long", "hair_short", "hair_buzz", "hair_braids", "hair_afro", "hair_bald"]
    static let hairColors = ["hc_black", "hc_darkbrown", "hc_blonde", "hc_red", "hc_grey", "hc_white"]
    static let eyeColors = ["eye_brown", "eye_blue", "eye_green", "eye_hazel", "eye_grey", "eye_amber"]
    static let builds = ["body_slim", "body_athletic", "body_curvy", "body_heavy", "body_muscular"]
    static let styles = ["casual", "suits", "streetstyle", "retro", "theatrical", "goth"]
    static let accessories = ["none", "glasses", "jewelry", "hat"]

    /// "hair_darkbrown" / "hc_darkbrown" / "body_slim" -> "Dark Brown" / "Slim"
    static func label(for id: String) -> String {
        var text = id
        for prefix in ["hair_", "hc_", "eye_", "body_"] where text.hasPrefix(prefix) {
            text.removeFirst(prefix.count)
            break
        }
        return text.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
