import SwiftUI
import SwiftData

@main
struct JournAIApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}
