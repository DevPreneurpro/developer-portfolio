import SwiftUI
import SwiftData

struct NewEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var messages: [ChatMessage] = []
    @State private var draft = ""
    @State private var isThinking = false
    @State private var isSaving = false

    private let service: AICompanionService = MockAICompanionService()

    private var userText: String {
        messages
            .filter { $0.role == .user }
            .map(\.text)
            .joined(separator: " ")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        if isThinking {
                            TypingIndicator()
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            inputBar
        }
        .background(Color("JournalBackground").ignoresSafeArea())
        .task {
            guard messages.isEmpty else { return }
            messages.append(ChatMessage(role: .ai, text: service.opener()))
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("JournalInk"))
            }
            ZStack {
                Circle().fill(Color("JournalAccentTint")).frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                    .foregroundColor(Color("JournalAccentDark"))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Sage")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("JournalInk"))
                Text("listening")
                    .font(.system(size: 11))
                    .foregroundColor(Color("JournalInkSoft"))
            }
            Spacer()
            Button {
                Task { await finishEntry() }
            } label: {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Done")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(userText.isEmpty ? Color("JournalInkFaint") : Color("JournalAccentDark"))
                }
            }
            .disabled(userText.isEmpty || isSaving)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color("JournalBackground"))
        .overlay(Rectangle().fill(Color("JournalBorder")).frame(height: 1), alignment: .bottom)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Write or speak…", text: $draft, axis: .vertical)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("JournalCard"))
                .overlay(Capsule().stroke(Color("JournalBorder"), lineWidth: 1))
                .clipShape(Capsule())

            Button {
                send()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("JournalBackground"))
                    .frame(width: 40, height: 40)
                    .background(
                        draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color("JournalInkFaint")
                            : Color("JournalAccentDark")
                    )
                    .clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("JournalBackground"))
        .overlay(Rectangle().fill(Color("JournalBorder")).frame(height: 1), alignment: .top)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(role: .user, text: text))
        draft = ""
        Task {
            isThinking = true
            let reply = await service.reply(to: messages)
            isThinking = false
            messages.append(ChatMessage(role: .ai, text: reply))
        }
    }

    private func finishEntry() async {
        guard !userText.isEmpty else { return }
        isSaving = true
        let (reflection, tags) = await service.reflect(on: userText)
        let entry = JournalEntry(mood: .neutral, text: userText, aiReflection: reflection, tags: tags)
        modelContext.insert(entry)
        isSaving = false
        dismiss()
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.text)
                .font(.system(size: 15))
                .foregroundColor(Color("JournalInk"))
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(message.role == .user ? Color("JournalAccentTint") : Color("JournalCard"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("JournalBorder"), lineWidth: message.role == .ai ? 1 : 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if message.role == .ai { Spacer(minLength: 40) }
        }
    }
}

private struct TypingIndicator: View {
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { _ in
                Circle().fill(Color("JournalInkFaint")).frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color("JournalCard"))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("JournalBorder"), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NewEntryView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
