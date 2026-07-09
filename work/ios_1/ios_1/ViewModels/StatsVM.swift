import Foundation
internal import Combine

@MainActor
final class StatsVM: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    func load() {
        sessions = GameSessionStore.loadAll().sorted { $0.timestamp > $1.timestamp }
    }

    func resetAll() {
        GameSessionStore.resetAll()
        sessions = []
    }

    var totalGamesPlayed: Int {
        sessions.count
    }

    func totalScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.score }
    }

    func personalBest(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }

    var recentSessions: [GameSession] {
        Array(sessions.prefix(10))
    }
}
