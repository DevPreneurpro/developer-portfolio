import SwiftUI

struct MoodFaceView: View {
    let mood: Mood
    var isSelected: Bool = false
    var size: CGFloat = 44

    private var strokeColor: Color {
        isSelected ? Color("JournalAccentDark") : Color("JournalInkFaint")
    }

    private var mouthCurveHeight: CGFloat {
        switch mood {
        case .veryLow: return -6
        case .low: return -3
        case .neutral: return 0
        case .good: return 4
        case .great: return 8
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color("JournalAccentTint") : Color.clear)
            Circle()
                .stroke(strokeColor, lineWidth: 1.5)

            HStack(spacing: size * 0.18) {
                Circle().fill(strokeColor).frame(width: size * 0.06, height: size * 0.06)
                Circle().fill(strokeColor).frame(width: size * 0.06, height: size * 0.06)
            }
            .offset(y: -size * 0.08)

            Path { path in
                let w = size * 0.36
                let h: CGFloat = 12
                path.move(to: CGPoint(x: 0, y: h / 2))
                path.addQuadCurve(
                    to: CGPoint(x: w, y: h / 2),
                    control: CGPoint(x: w / 2, y: h / 2 + mouthCurveHeight * (size / 44))
                )
            }
            .stroke(strokeColor, lineWidth: 1.5)
            .frame(width: size * 0.36, height: 12)
            .offset(y: size * 0.14)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack {
        ForEach(Mood.allCases) { mood in
            MoodFaceView(mood: mood, isSelected: mood == .neutral)
        }
    }
    .padding()
}
