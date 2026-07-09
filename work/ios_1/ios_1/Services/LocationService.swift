import Foundation
import CoreLocation

final class LocationService: NSObject {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        // Stub — will configure and request location permission in a later step
    }
}
