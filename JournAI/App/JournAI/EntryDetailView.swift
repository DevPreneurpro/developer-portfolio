import SwiftUI
import SwiftData

struct EntryDetailView: View {
    let entry: JournalEntry

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 8) {
                    MoodFaceView(mood: entry.mood, isSelected: false, size: 30)
                    Text(entry.mood.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("JournalInkSoft"))
                    Text("·")
                        .foregroundColor(Color("JournalInkFaint"))
                    Text(entry.date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 13))
                        .foregroundColor(Color("JournalInkFaint"))
                }

                Text(entry.text)
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(Color("JournalInk"))
                    .lineSpacing(6)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13))
                            .foregroundColor(Color("JournalAccentDark"))
                        Text("AI REFLECTION")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("JournalAccentDark"))
                    }
                    Text(entry.aiReflection)
                        .font(.system(size: 15, design: .serif))
                        .italic()
                        .foregroundColor(Color("JournalInk"))

                    if !entry.tags.isEmpty {
                        HStack {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color("JournalAccentDark"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.6))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(18)
                .background(Color("JournalAccentTint"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(20)
        }
        .background(Color("JournalBackground").ignoresSafeArea())
        .navigationTitle(entry.date.formatted(.dateTime.weekday(.wide).month().day()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Delete this entry?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
