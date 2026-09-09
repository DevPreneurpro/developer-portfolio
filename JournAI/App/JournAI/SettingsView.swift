import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [JournalEntry]

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("companionName") private var companionName = "Sage"
    @AppStorage("companionPersonality") private var companionPersonality = "Calm & Curious"
    @AppStorage("voiceRepliesEnabled") private var voiceRepliesEnabled = true
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 21
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("faceIDLockEnabled") private var faceIDLockEnabled = true

    @State private var showingDeleteAllConfirmation = false

    private let personalities = ["Calm & Curious", "Warm & Direct", "Playful", "Quiet Listener"]

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: .now) ?? .now
            },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = comps.hour ?? 21
                reminderMinute = comps.minute ?? 0
            }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    accountCard

                    settingsSection(title: "AI COMPANION") {
                        settingsRow(label: "Companion Name") {
                            TextField("Name", text: $companionName)
                                .multilineTextAlignment(.trailing)
                        }
                        rowDivider
                        settingsRow(label: "Personality") {
                            Picker("Personality", selection: $companionPersonality) {
                                ForEach(personalities, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        rowDivider
                        settingsRow(label: "Voice Replies") {
                            Toggle("", isOn: $voiceRepliesEnabled).labelsHidden()
                        }
                    }

                    settingsSection(title: "REMINDERS") {
                        settingsRow(label: "Daily Check-in") {
                            Toggle("", isOn: $dailyReminderEnabled).labelsHidden()
                        }
                        if dailyReminderEnabled {
                            rowDivider
                            settingsRow(label: "Reminder Time") {
                                DatePicker("", selection: reminderTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                        }
                    }

                    settingsSection(title: "PRIVACY & DATA") {
                        settingsRow(label: "Face ID Lock") {
                            Toggle("", isOn: $faceIDLockEnabled).labelsHidden()
                        }
                        rowDivider
                        Button {
                            showingDeleteAllConfirmation = true
                        } label: {
                            HStack {
                                Text("Delete All Entries (\(entries.count))")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("JournalDanger"))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                        }
                    }

                    Button("Sign Out") {
                        hasCompletedOnboarding = false
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("JournalDanger"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .padding(18)
                .padding(.bottom, 90)
            }
            .background(Color("JournalBackground").ignoresSafeArea())
            .navigationTitle("Settings")
        }
        .confirmationDialog(
            "Delete all \(entries.count) entries? This can't be undone.",
            isPresented: $showingDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                for entry in entries { modelContext.delete(entry) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var accountCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color("JournalAccentTint")).frame(width: 52, height: 52)
                Text("A").font(.system(size: 19, design: .serif)).foregroundColor(Color("JournalAccentDark"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Alex Rivera").font(.system(size: 16, weight: .semibold)).foregroundColor(Color("JournalInk"))
                Text("alex.rivera@icloud.com").font(.system(size: 13)).foregroundColor(Color("JournalInkSoft"))
            }
            Spacer()
        }
        .padding(16)
        .background(Color("JournalCard"))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color("JournalBorder"), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var rowDivider: some View {
        Divider().padding(.leading, 16)
    }

    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("JournalInkSoft"))
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content()
            }
            .background(Color("JournalCard"))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color("JournalBorder"), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    @ViewBuilder
    private func settingsRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color("JournalInk"))
            Spacer()
            content()
                .tint(Color("JournalAccentDark"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
