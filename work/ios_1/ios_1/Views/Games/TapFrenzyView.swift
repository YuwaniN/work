import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyVM()

    var body: some View {
        VStack(spacing: 30) {

            Text("Time: \(viewModel.timeRemaining)")
                .font(.largeTitle)

            Text("Score: \(viewModel.score)")
                .font(.title)

            Text("Combo x\(viewModel.multiplier)")
                .font(.headline)

            if viewModel.state == .playing {
                Button {
                    viewModel.tap()
                } label: {
                    Text("TAP")
                        .frame(width: 180, height: 180)
                        .background(viewModel.isGreen ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .transition(.scale.combined(with: .opacity))
            }

            if viewModel.state == .gameOver {
                VStack(spacing: 15) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text("High Score: \(viewModel.currentHighScore)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Button("Play Again") {
                        withAnimation {
                            viewModel.startGame()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .navigationTitle("Tap Frenzy")
        .animation(.easeInOut, value: viewModel.state)
        .onAppear {
            viewModel.startGame()
        }
    }
}

#Preview {
    NavigationStack { TapFrenzyView() }
}
