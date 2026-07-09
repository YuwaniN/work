import Foundation

// MARK: - Persistence store for completed game sessions

enum GameSessionStore {
    private static let key = "gameSessions"

    /// All saved sessions, most recent first.
    static var all: [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let sessions = try? JSONDecoder().decode([GameSession].self, from: data)
        return sessions?.sorted(by: { $0.timestamp > $1.timestamp }) ?? []
    }

    /// Append a session and persist immediately.
    static func append(_ session: GameSession) {
        var existing = all
        existing.append(session)
        save(existing)
    }

    /// Load all sessions (alias used by StatsVM).
    static func loadAll() -> [GameSession] {
        all
    }

    /// Remove every stored session.
    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Remove every stored session (alias used by StatsVM).
    static func resetAll() {
        reset()
    }

    private static func save(_ sessions: [GameSession]) {
        let data = try? JSONEncoder().encode(sessions)
        UserDefaults.standard.set(data, forKey: key)
    }
}
