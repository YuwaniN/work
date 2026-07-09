import SwiftUI
internal import Combine

// MARK: - View State

enum TapFrenzyViewState {
    case playing
    case gameOver
}

// MARK: - View Model

@MainActor
final class TapFrenzyVM: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var timeRemaining = 10
    @Published private(set) var multiplier = 1
    @Published private(set) var isGreen = true
    @Published private(set) var state: TapFrenzyViewState = .playing

    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    private var lastTapTime = Date()
    private var gameTimerCancellable: AnyCancellable?
    private var colorTimerCancellable: AnyCancellable?

    var currentHighScore: Int {
        highScore
    }

    // MARK: - Start / Reset

    func startGame() {
        score = 0
        timeRemaining = 10
        multiplier = 1
        isGreen = true
        lastTapTime = Date()
        state = .playing
        startTimers()
    }

    // MARK: - Tap

    func tap() {
        guard state == .playing else { return }

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
    }

    // MARK: - Timers

    private func startTimers() {
        stopTimers()

        gameTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

        colorTimerCancellable = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.toggleColor()
            }
    }

    private func stopTimers() {
        gameTimerCancellable?.cancel()
        gameTimerCancellable = nil
        colorTimerCancellable?.cancel()
        colorTimerCancellable = nil
    }

    private func tick() {
        guard state == .playing else { return }
        timeRemaining -= 1

        if timeRemaining == 0 {
            state = .gameOver
            stopTimers()
            if score > highScore {
                highScore = score
            }
        }
    }

    private func toggleColor() {
        guard state == .playing else { return }
        isGreen.toggle()
    }
}
