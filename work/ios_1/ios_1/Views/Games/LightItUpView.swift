import SwiftUI

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpVM()

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.level.columns)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                HStack {
                    Text("Time: \(viewModel.timeRemaining)")
                        .font(.title2)
                    Spacer()
                    livesView
                    Spacer()
                    Text(viewModel.level.label)
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(viewModel.level.glowColor.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text("Score: \(viewModel.score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if viewModel.state == .playing {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.cards) { card in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(card.isLit ? viewModel.level.glowColor : Color(.systemGray5))
                                .frame(height: 80)
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .onTapGesture {
                                    viewModel.tapCard(card)
                                }
                        }
                    }
                    .animation(.easeInOut(duration: 0.15), value: viewModel.cards.map { $0.isLit })
                    .transition(.opacity)
                } else {
                    VStack(spacing: 15) {
                        Text(viewModel.lives == 0 ? "Out of Lives!" : "Round Over!")
                            .font(.largeTitle)
                            .foregroundColor(.red)

                        Text("High Score: \(viewModel.currentHighScore)")
                            .font(.title2)
                            .fontWeight(.bold)

                        ShareLink(item: "I just scored \(viewModel.score) on Light It Up — beat that! ⚡") {
                            Label("Share Score", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)

                        Button("Play Again") {
                            withAnimation {
                                viewModel.startGame()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }
            .padding()

            if viewModel.showLevelUpFlash {
                levelUpFlash
            }
        }
        .navigationTitle("Light It Up")
        .onAppear {
            viewModel.startGame()
        }
    }

    private var livesView: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
    }

    private var levelUpFlash: some View {
        VStack(spacing: 8) {
            Text("Level Up!")
                .font(.title)
                .fontWeight(.bold)
            Text(viewModel.level.label)
                .font(.system(size: 48, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(40)
        .background(viewModel.level.glowColor.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    NavigationStack { LightItUpView() }
}
