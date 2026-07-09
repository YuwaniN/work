import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Reflex Arcade")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                NavigationLink("Tap Frenzy") {
                    TapFrenzyView()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)

                NavigationLink("Light It Up") {
                    LightItUpView()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)

                NavigationLink("Quiz Rush") {
                    QuizRushView()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeTab()
}
