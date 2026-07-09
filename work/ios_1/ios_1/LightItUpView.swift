import SwiftUI
internal import Combine

struct LightItUpView: View {
    @AppStorage("roundLength") private var roundLength = 60
    @AppStorage("lightItUpHighScore") private var highScore = 0

    @State private var score = 0
    @State private var lives = 3
    @State private var timeRemaining = 60
    @State private var level: Level = .l1
    @State private var cards: [Card] = []
    @State private var elapsedSinceTick: Double = 0
    @State private var showLevelUpFlash = false

    // Drives the once-a-second countdown + level checks.
    let secondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Fast heartbeat lets us honour lit-window durations shorter than 1s
    // (down to 0.8s at L4) without recreating a Timer on every level change.
    let heartbeat = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    /// The round is over either when time runs out or lives hit zero.
    private var roundActive: Bool {
        timeRemaining > 0 && lives > 0
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: level.columns)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                HStack {
                    Text("Time: \(timeRemaining)")
                        .font(.title2)
                    Spacer()
                    livesView
                    Spacer()
                    Text(level.label)
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(level.glowColor.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text("Score: \(score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if roundActive {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(cards) { card in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(card.isLit ? level.glowColor : Color(.systemGray5))
                                .frame(height: 80)
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .onTapGesture {
                                    handleTap(card)
                                }
                        }
                    }
                    .animation(.easeInOut(duration: 0.15), value: cards.map { $0.isLit })
                    .transition(.opacity)
                } else {
                    VStack(spacing: 15) {
                        Text(lives == 0 ? "Out of Lives!" : "Round Over!")
                            .font(.largeTitle)
                            .foregroundColor(.red)

                        Text("High Score: \(highScore)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Button("Play Again") {
                            withAnimation {
                                resetRound()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }
            .padding()

            if showLevelUpFlash {
                levelUpFlash
            }
        }
        .navigationTitle("Light It Up")
        .onAppear {
            timeRemaining = roundLength
            setUpCards(for: level)
        }
        .onReceive(secondTimer) { _ in
            guard roundActive else { return }
            timeRemaining -= 1

            let elapsedRound = roundLength - timeRemaining
            let newLevel = Level.forElapsed(elapsedRound, roundLength: roundLength)
            if newLevel != level {
                level = newLevel
                setUpCards(for: level)
                triggerLevelUpFlash()
            }

            if timeRemaining == 0 {
                checkHighScore()
            }
        }
        .onReceive(heartbeat) { _ in
            guard roundActive else { return }
            elapsedSinceTick += 0.1
            if elapsedSinceTick >= level.litWindow {
                elapsedSinceTick = 0
                relight()
            }
        }
    }

    private var livesView: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < lives ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
    }

    private var levelUpFlash: some View {
        VStack(spacing: 8) {
            Text("Level Up!")
                .font(.title)
                .fontWeight(.bold)
            Text(level.label)
                .font(.system(size: 48, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(40)
        .background(level.glowColor.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .transition(.opacity.combined(with: .scale))
    }

    private func setUpCards(for level: Level) {
        cards = (0..<level.cardCount).map { Card(id: $0) }
        elapsedSinceTick = 0
        relight()
    }

    /// Turns all cards dark, then lights up a fresh random set
    /// (2 cards at once once we hit L4).
    private func relight() {
        for index in cards.indices {
            cards[index].isLit = false
        }
        let indicesToLight = Array(cards.indices).shuffled().prefix(level.simultaneousLitCount)
        for index in indicesToLight {
            cards[index].isLit = true
        }
    }

    private func handleTap(_ card: Card) {
        guard roundActive,
              let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        withAnimation {
            if cards[index].isLit {
                score += 2
                cards[index].isLit = false
            } else {
                lives -= 1
                if lives == 0 {
                    checkHighScore()
                }
            }
        }
    }

    private func checkHighScore() {
        if score > highScore {
            highScore = score
        }
    }

    private func triggerLevelUpFlash() {
        withAnimation(.easeIn(duration: 0.15)) {
            showLevelUpFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                showLevelUpFlash = false
            }
        }
    }

    private func resetRound() {
        score = 0
        lives = 3
        timeRemaining = roundLength
        level = .l1
        elapsedSinceTick = 0
        showLevelUpFlash = false
        setUpCards(for: level)
    }
}

#Preview {
    NavigationStack { LightItUpView() }
}
