import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            Color("JournalBackground")
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("JournalAccentTint").opacity(0.55), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 170
                    )
                )
                .frame(width: 340, height: 340)
                .position(x: -20, y: -40)

            VStack(spacing: 0) {
                Spacer(minLength: 90)

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(Color("JournalAccentTint"))
                            .frame(width: 68, height: 68)
                        Image(systemName: "book.closed")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundColor(Color("JournalAccentDark"))
                    }

                    VStack(spacing: 10) {
                        (
                            Text("journ")
                                .foregroundColor(Color("JournalInk"))
                            +
                            Text("AI")
                                .foregroundColor(Color("JournalAccentDark"))
                                .fontWeight(.semibold)
                        )
                        .font(.system(size: 34, design: .serif))

                        Text("Your thoughts, held gently.")
                            .font(.system(size: 16, design: .serif))
                            .italic()
                            .foregroundColor(Color("JournalInkSoft"))
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        // TODO: wire up Sign in with Apple
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                            Text("Continue with Apple")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                    }
                    .foregroundColor(Color("JournalBackground"))
                    .background(Color("JournalInk"))
                    .clipShape(Capsule())

                    Button {
                        // TODO: navigate to email sign-in
                    } label: {
                        Text("Continue with Email")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                    .foregroundColor(Color("JournalInk"))
                    .overlay(
                        Capsule().stroke(Color("JournalInkFaint"), lineWidth: 1.5)
                    )

                    HStack(spacing: 4) {
                        Text("Already journaling with us?")
                            .foregroundColor(Color("JournalInkSoft"))
                        Button("Sign in") {
                            // TODO: navigate to sign-in
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(Color("JournalAccentDark"))
                    }
                    .font(.system(size: 14))
                    .padding(.top, 6)

                    Text("By continuing you agree to our Terms & Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(Color("JournalInkFaint"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
