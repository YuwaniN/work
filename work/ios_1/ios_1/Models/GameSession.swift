import Foundation
import CoreLocation

struct GameSession: Codable, Identifiable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(
        mode: GameMode,
        score: Int,
        latitude: Double = 0,
        longitude: Double = 0,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
