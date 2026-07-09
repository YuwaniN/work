import Foundation
internal import Combine

@MainActor
final class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []

    func load() {
        // Stub — will load persisted sessions in a later step
    }
}
