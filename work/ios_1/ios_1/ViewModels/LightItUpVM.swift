import SwiftUI
import CoreLocation
internal import Combine

// MARK: - View State

enum LightItUpViewState {
    case playing
    case roundOver
}

// MARK: - View Model

@MainActor
final class LightItUpVM: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var lives = 3
    @Published private(set) var timeRemaining = 60
    @Published private(set) var level: Level = .l1
    @Published private(set) var cards: [Card] = []
    @Published private(set) var showLevelUpFlash = false
    @Published private(set) var state: LightItUpViewState = .playing

    @AppStorage("lightItUpHighScore") private var highScore = 0
    @AppStorage("roundLength") private var roundLength = 60

    private var elapsedSinceTick: Double = 0
    private var secondTimerCancellable: AnyCancellable?
    private var heartbeatCancellable: AnyCancellable?

    var currentHighScore: Int {
        highScore
    }

    var roundActive: Bool {
        timeRemaining > 0 && lives > 0
    }

    // MARK: - Start / Reset

    func startGame() {
        score = 0
        lives = 3
        timeRemaining = roundLength
        level = .l1
        showLevelUpFlash = false
        elapsedSinceTick = 0
        state = .playing
        setUpCards(for: level)
        startTimers()
    }

    // MARK: - Tap

    func tapCard(_ card: Card) {
        guard state == .playing, roundActive,
              let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        withAnimation {
            if cards[index].isLit {
                score += 2
                cards[index].isLit = false
            } else {
                lives -= 1
                if lives == 0 {
                    endRound()
                }
            }
        }
    }

    // MARK: - Timers

    private func startTimers() {
        stopTimers()

        secondTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

        heartbeatCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.heartbeat()
            }
    }

    private func stopTimers() {
        secondTimerCancellable?.cancel()
        secondTimerCancellable = nil
        heartbeatCancellable?.cancel()
        heartbeatCancellable = nil
    }

    private func tick() {
        guard state == .playing, roundActive else { return }
        timeRemaining -= 1

        let elapsedRound = roundLength - timeRemaining
        let newLevel = Level.forElapsed(elapsedRound, roundLength: roundLength)
        if newLevel != level {
            level = newLevel
            setUpCards(for: level)
            triggerLevelUpFlash()
        }

        if timeRemaining == 0 {
            endRound()
        }
    }

    private func heartbeat() {
        guard state == .playing, roundActive else { return }
        elapsedSinceTick += 0.1
        if elapsedSinceTick >= level.litWindow {
            elapsedSinceTick = 0
            relight()
        }
    }

    // MARK: - Cards

    private func setUpCards(for level: Level) {
        cards = (0..<level.cardCount).map { Card(id: $0) }
        elapsedSinceTick = 0
        relight()
    }

    private func relight() {
        for index in cards.indices {
            cards[index].isLit = false
        }
        let indicesToLight = Array(cards.indices).shuffled().prefix(level.simultaneousLitCount)
        for index in indicesToLight {
            cards[index].isLit = true
        }
    }

    // MARK: - Level Up

    private func triggerLevelUpFlash() {
        withAnimation(.easeIn(duration: 0.15)) {
            showLevelUpFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.showLevelUpFlash = false
            }
        }
    }

    // MARK: - End Round

    private func endRound() {
        state = .roundOver
        stopTimers()
        if score > highScore {
            highScore = score
        }
        let coordinate = LocationService.shared.currentLocation
        GameSessionStore.append(
            GameSession(
                mode: .lightItUp,
                score: score,
                latitude: coordinate?.latitude ?? 0,
                longitude: coordinate?.longitude ?? 0
            )
        )
    }
}
