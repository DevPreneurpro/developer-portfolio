import SwiftUI

struct MainTabView: View {
    private enum Tab { case home, settings }

    @State private var selectedTab: Tab = .home
    @State private var showingNewEntry = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(onStartJournaling: { showingNewEntry = true })
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(Tab.home)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .tag(Tab.settings)
            }
            .tint(Color("JournalAccentDark"))

            Button {
                showingNewEntry = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color("JournalBackground"))
                    .frame(width: 60, height: 60)
                    .background(Color("JournalAccentDark"))
                    .clipShape(Circle())
                    .shadow(color: Color("JournalAccentDark").opacity(0.35), radius: 10, y: 4)
            }
            .padding(.bottom, 32)
        }
        .fullScreenCover(isPresented: $showingNewEntry) {
            NewEntryView()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
