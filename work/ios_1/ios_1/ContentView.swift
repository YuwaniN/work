import SwiftUI

struct ContentView: View {
    @State private var showSettings = false

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
