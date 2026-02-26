import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var currentLocation: CLLocation?
    var onLocationChange: (() -> Void)?

    override init() {
        let manager = CLLocationManager()
        self.locationManager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 300
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var canRequestAuthorization: Bool {
        authorizationStatus == .notDetermined
    }

    func requestAuthorizationIfNeeded() {
        guard canRequestAuthorization else {
            if isAuthorized {
                requestLocation()
            }
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        guard isAuthorized else {
            return
        }
        locationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized {
            requestLocation()
        }
        onLocationChange?()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
            return
        }
        currentLocation = latestLocation
        onLocationChange?()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
}
