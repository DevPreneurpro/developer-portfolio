import SwiftUI

struct CompanionAppearanceView: View {
    @ObservedObject private var store = CompanionAppearanceStore.shared
    @State private var isGeneratingPortrait = false
    @State private var isGeneratingClips = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                portraitPreview

                traitPicker(title: "Gender", selection: $store.appearance.gender, options: CompanionAppearance.genders)
                traitPicker(title: "Age", selection: $store.appearance.age, options: CompanionAppearance.ages)
                traitPicker(title: "Ethnicity", selection: $store.appearance.ethnicity, options: CompanionAppearance.ethnicities)
                traitPicker(title: "Build", selection: $store.appearance.build, options: CompanionAppearance.builds)
                traitPicker(title: "Hair Style", selection: $store.appearance.hair, options: CompanionAppearance.hairStyles)
                traitPicker(title: "Hair Color", selection: $store.appearance.hairColor, options: CompanionAppearance.hairColors)
                traitPicker(title: "Eye Color", selection: $store.appearance.eyeColor, options: CompanionAppearance.eyeColors)
                traitPicker(title: "Style", selection: $store.appearance.style, options: CompanionAppearance.styles)
                traitPicker(title: "Accessory", selection: $store.appearance.accessory, options: CompanionAppearance.accessories)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(Color("JournalDanger"))
                }

                Button {
                    Task { await generatePortrait() }
                } label: {
                    Group {
                        if isGeneratingPortrait {
                            ProgressView()
                        } else {
                            Text(store.portraitURL == nil ? "Generate Portrait" : "Regenerate Portrait")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .foregroundColor(Color("JournalBackground"))
                .background(Color("JournalAccentDark"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(isGeneratingPortrait)

                if store.portraitURL != nil {
                    Button {
                        Task { await generateClips() }
                    } label: {
                        Group {
                            if isGeneratingClips {
                                ProgressView()
                            } else {
                                Text(store.idleClipURL == nil ? "Generate Talking Animation" : "Regenerate Animation")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .foregroundColor(Color("JournalInk"))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("JournalInkFaint"), lineWidth: 1.5))
                    .disabled(isGeneratingClips)

                    Text("This generates two short clips (~5s each) once — they're reused for every chat, not regenerated per message.")
                        .font(.footnote)
                        .foregroundColor(Color("JournalInkSoft"))
                }
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .background(Color("JournalBackground").ignoresSafeArea())
        .navigationTitle("Companion's Look")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var portraitPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("JournalCard"))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color("JournalBorder"), lineWidth: 1))
                .frame(height: 260)

            if let url = store.portraitURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(Color("JournalInkFaint"))
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 36))
                        .foregroundColor(Color("JournalInkFaint"))
                    Text("No portrait yet — pick a look below and generate one")
                        .font(.footnote)
                        .foregroundColor(Color("JournalInkSoft"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
    }

    private func traitPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("JournalInkSoft"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        let isSelected = selection.wrappedValue == option
                        Button {
                            selection.wrappedValue = option
                        } label: {
                            Text(CompanionAppearance.label(for: option))
                                .font(.system(size: 14))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color("JournalAccentDark") : Color("JournalCard"))
                                .foregroundColor(isSelected ? Color("JournalBackground") : Color("JournalInk"))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color("JournalBorder"), lineWidth: isSelected ? 0 : 1)
                                )
                        }
                    }
                }
            }
        }
    }

    private func generatePortrait() async {
        errorMessage = nil
        isGeneratingPortrait = true
        defer { isGeneratingPortrait = false }
        do {
            let url = try await CompanionAvatarService.generatePortrait(for: store.appearance)
            store.setPortrait(url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func generateClips() async {
        guard let portraitURL = store.portraitURL else { return }
        errorMessage = nil
        isGeneratingClips = true
        defer { isGeneratingClips = false }
        do {
            let clips = try await CompanionAvatarService.generateClips(portraitURL: portraitURL)
            store.setClips(idle: clips.idle, talking: clips.talking)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        CompanionAppearanceView()
    }
}
