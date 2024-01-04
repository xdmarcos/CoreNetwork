//
//  Location.swift
//
//
//  Created by Marcos A. González Piñeiro on 03/01/2024.
//

import CoreLocation
import os

public enum UserAuthorizationType: Equatable, CustomDebugStringConvertible {
    case `default`
    case whenInUse
    case always

    public var debugDescription: String {
        switch self {
        case .default: return "default"
        case .whenInUse: return "whenInUse"
        case .always: return "always"
        }
    }
}

public enum LocationManagerError: Error, Equatable {
    case alwaysAuthorizationRequired
    case locationServiceNotEnabled
    case locationNotFound
    case locationUpdatesCouldNotStart
}

public class LocationManager: NSObject {
    private let logger: Logger
    private let locationManager: CLLocationManager
    private var updatesStarted = false

    public var location: CLLocation?

    public override init() {
        self.logger = Logger(subsystem: "xdmgz.dev.locationModule", category: "LocationsHandler")

        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    public func requestPermissions() async throws {
        self.locationManager.delegate = self

        guard await locationServicesEnabled() else {
            logger.error("📍 \(Self.self):\(#line) Location service is not enable on device")
            throw LocationManagerError.locationServiceNotEnabled
        }

        switch authorizationStatus() {
        case .notDetermined:
            requestUserAuthorization(type: .always)
        case .restricted, .denied, .authorizedWhenInUse:
            logger.error("📍 \(Self.self):\(#line) Location always authorization required")
            throw LocationManagerError.alwaysAuthorizationRequired
        case .authorizedAlways: break
        @unknown default: break
        }
    }

    public func locationServicesEnabled() async -> Bool {
        let servicesEnabled = CLLocationManager.locationServicesEnabled()
        logger.info("📍 \(Self.self):\(#line) locationServicesEnabled: \(servicesEnabled)")
        return servicesEnabled
    }

    public func authorizationStatus() -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus
        logger.info("📍 \(Self.self):\(#line) authorizationStatus: \(status.rawValue)")
        return status
    }

    public func requestUserAuthorization(type: UserAuthorizationType) {
        logger.info("📍 \(Self.self):\(#line) Request location authorization for \(type.debugDescription)")

        switch type {
        case .default: locationManager.requestLocation()
        case .whenInUse: locationManager.requestWhenInUseAuthorization()
        case .always: locationManager.requestAlwaysAuthorization()
        }
    }

    public func startLocationUpdates() -> AsyncStream<Result<CLLocation, LocationManagerError>> {
        logger.info("📍 \(Self.self):\(#line) startCurrentLocationUpdates")

        return AsyncStream { [weak self] continuation in
            guard let self = self else { return }

            Task {
                do {
                    self.updatesStarted = true
                    for try await locationUpdate in CLLocationUpdate.liveUpdates() {
                        // End location updates by breaking out of the loop.
                        guard self.updatesStarted == true else {
                            continuation.finish()
                            break
                        }

                        guard let location = locationUpdate.location else {
                            continuation.yield(.failure(.locationNotFound))
                            return
                        }

                        self.location = location
                        self.logger.info("📍 \(Self.self):\(#line) New Device location ->")
                        self.logger.info("📍 \(Self.self):\(#line) coordinate: \(location.coordinate.latitude), \(location.coordinate.longitude), altitude: \(location.altitude)")
                        continuation.yield(.success(location))
                    }
                } catch {
                    self.logger.error("📍 \(Self.self):\(#line) locationUpdatesCouldNotStart: \(error)")
                    continuation.yield(.failure(.locationUpdatesCouldNotStart))
                    continuation.finish()
                }
            }
        }
    }

    public func stopLocationUpdates() {
        self.logger.info("📍 \(Self.self):\(#line) Stopping location updates")
        self.updatesStarted = false
    }

    func hasLocationPermission() async -> Bool {
        var hasPermission = false

        if await locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                hasPermission = false
            case .authorizedAlways, .authorizedWhenInUse:
                hasPermission = true
            @unknown default:
                    break
            }
        } else {
            hasPermission = false
        }

        return hasPermission
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.info("📍 \(Self.self):\(#line) didUpdateLocations with: \(locations)")
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("📍 \(Self.self):\(#line) didFailWithError with: \(error)")
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        logger.info("📍 \(Self.self):\(#line) locationManagerDidChangeAuthorization with: \(manager.authorizationStatus.rawValue)")
    }
}
