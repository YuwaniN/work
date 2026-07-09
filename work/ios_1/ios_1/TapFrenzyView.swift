import SwiftUI
internal import Combine

struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var multiplier = 1
    @State private var lastTapTime = Date()

    @State private var isGreen = true
    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let colorTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 30) {

            Text("Time: \(timeRemaining)")
                .font(.largeTitle)

            Text("Score: \(score)")
                .font(.title)

            Text("Combo x\(multiplier)")
                .font(.headline)

            if timeRemaining > 0 {
                Button {
                    let currentTime = Date()
                    let difference = currentTime.timeIntervalSince(lastTapTime)

                    if difference <= 0.5 {
                        multiplier += 1
                    } else {
                        multiplier = 1
                    }

                    lastTapTime = currentTime

                    if isGreen {
                        score += multiplier + 1
                    } else {
                        score -= 1
                    }
                } label: {
                    Text("TAP")
                        .frame(width: 180, height: 180)
                        .background(isGreen ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .transition(.scale.combined(with: .opacity))
            }

            if timeRemaining == 0 {
                VStack(spacing: 15) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text("High Score: \(highScore)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Button("Play Again") {
                        withAnimation {
                            score = 0
                            timeRemaining = 10
                            multiplier = 1
                            isGreen = true
                            lastTapTime = Date()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .navigationTitle("Tap Frenzy")
        .animation(.easeInOut, value: timeRemaining == 0)
        .onReceive(gameTimer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1

                if timeRemaining == 0 {
                    if score > highScore {
                        highScore = score
                    }
                }
            }
        }
        .onReceive(colorTimer) { _ in
            if timeRemaining > 0 {
                isGreen.toggle()
            }
        }
    }
}

#Preview {
    NavigationStack { TapFrenzyView() }
}
