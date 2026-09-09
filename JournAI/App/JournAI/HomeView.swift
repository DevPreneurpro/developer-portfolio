import SwiftUI
import SwiftData

struct HomeView: View {
    var onStartJournaling: () -> Void

    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var selectedMood: Mood?

    private var streak: Int {
        let calendar = Calendar.current
        let entryDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var day = calendar.startOfDay(for: .now)
        var count = 0
        while entryDays.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    streakRow
                    moodCard
                    promptCard
                    recentEntriesSection
                }
                .padding(20)
                .padding(.bottom, 90)
            }
            .background(Color("JournalBackground").ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("JournalInkSoft"))
                Text("Alex")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Color("JournalInk"))
            }
            Spacer()
            ZStack {
                Circle().fill(Color("JournalAccentTint")).frame(width: 44, height: 44)
                Text("A")
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(Color("JournalAccentDark"))
            }
        }
    }

    private var streakRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color("JournalAccentDark"))
                Text(streak > 0 ? "\(streak)-day streak" : "Start your streak today")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("JournalAccentDark"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color("JournalAccentTint"))
            .clipShape(Capsule())

            Spacer()

            Text(Date.now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                .font(.system(size: 13))
                .foregroundColor(Color("JournalInkFaint"))
        }
    }

    private var moodCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How are you, right now?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("JournalInk"))
            HStack {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        MoodFaceView(mood: mood, isSelected: selectedMood == mood)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color("JournalCard"))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color("JournalBorder"), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TODAY'S PROMPT")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color("JournalBackground").opacity(0.75))
            Text("What's one thing you're carrying today that you haven't said out loud?")
                .font(.system(size: 19, design: .serif))
                .italic()
                .foregroundColor(Color("JournalBackground"))
            Button(action: onStartJournaling) {
                HStack(spacing: 6) {
                    Text("Start Journaling")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color("JournalAccentDark"))
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .background(Color("JournalBackground"))
                .clipShape(Capsule())
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("JournalAccentDark"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("JournalInk"))

            if entries.isEmpty {
                Text("Your entries will show up here once you start journaling.")
                    .font(.system(size: 14))
                    .foregroundColor(Color("JournalInkSoft"))
                    .padding(.vertical, 8)
            } else {
                ForEach(entries.prefix(5)) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct EntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            MoodFaceView(mood: entry.mood, isSelected: false, size: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(.dateTime.weekday(.wide).hour().minute()).uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color("JournalInkFaint"))
                Text("\"\(entry.text)\"")
                    .font(.system(size: 15, design: .serif))
                    .italic()
                    .foregroundColor(Color("JournalInk"))
                    .lineLimit(2)
                if let tag = entry.tags.first {
                    Text(tag)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("JournalAccentDark"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color("JournalAccentTint"))
                        .clipShape(Capsule())
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("JournalInkFaint"))
        }
        .padding(16)
        .background(Color("JournalCard"))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color("JournalBorder"), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HomeView(onStartJournaling: {})
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
