//
//  GeolocationViewModel.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 20/12/2023.
//

import CoreLocation
import CoreNetwork
import Foundation
import Location
import os
import UIKit

@MainActor
class GeolocationViewModel: ObservableObject {
    @Published var result: [LocationInfo]
    @Published var liveUpdatesDidStart = false

    let apiClient = ApiClient()
    let locationManager = LocationManager()
    let logger = Logger(subsystem: "xdmgz.dev.CoreNetworkExampleApp", category: "GeolocationViewModel")
    let maximumLocationUpdatesCount = 10

    var locationAuthorizationPromptMessage = ""
    var showLocationAuthorizationPrompt = false
    var location: CLLocation?

    init(result: [LocationInfo] = []) {
        self.result = result
    }

    func requestLocationAuthorization() async {
        do {
            try await locationManager.requestPermissions()
            try await startLocationUpdates()
            
        } catch {
            guard let locationError = error as? LocationManagerError else {
                return
            }

            switch locationError {
            case .alwaysAuthorizationRequired:
                locationAuthorizationPromptMessage = "We need always authorization, please go to Settings -> Privacy & Security -> Location Services find the App name and select `always`."
                showLocationAuthorizationPrompt = true
            case .locationServiceNotEnabled:
                locationAuthorizationPromptMessage = "Location services are not enable, go to Settings -> Privacy & Security -> Location Services and enable them."
                showLocationAuthorizationPrompt = true
            case .locationNotFound, .locationUpdatesCouldNotStart: break
            }
        }
    }

    func openLocationSettings() {
        UIApplication.shared.open(
            URL(string: UIApplication.openSettingsURLString)!, 
            options: [:],
            completionHandler: nil
        )
    }

    func startLocationUpdates() async throws {
        liveUpdatesDidStart = true
        for try await result in locationManager.startLocationUpdates() {
            switch result {
            case .success(let location):
                await reverseGeolocation(location: location)
            case .failure(let error):
                liveUpdatesDidStart = false
                logger.error("‼️ \(Self.self):\(#line) New location update error \(error)")
            }
        }
    }

    func stopLocationUpdates() {
        locationManager.stopLocationUpdates()
        liveUpdatesDidStart = false
    }
}

private extension GeolocationViewModel {
    func reverseGeolocation(location: CLLocation) async {
        guard location.coordinate.latitude != self.location?.coordinate.latitude,
              location.coordinate.longitude != self.location?.coordinate.longitude else { return }

        self.location = location

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let altitude = location.altitude

        let reverseGeolocationEndpointProvider = GeolocationEndpointProvider.reverseGeolocation(
            lat: "\(latitude)",
            lon: "\(longitude)"
        )

        do {
            let geoResult = try await apiClient.asyncRequest(
                endpoint: reverseGeolocationEndpointProvider,
                responseModel: GeolocationModel.self
            )

            self.result = geoResult.data.map { geoInfo in
                var address = ""
                if let street = geoInfo.street {
                    address += street
                }

                if let postalCode = geoInfo.postalCode {
                    address += ", \(postalCode)"
                }

                if let locality = geoInfo.locality {
                    address += ", \(locality)"
                }

                address += " (\(geoInfo.region))"

                return LocationInfo(
                    countryName: geoInfo.countryModule.commonName,
                    countryFlag: geoInfo.countryModule.flag,
                    address: address,
                    latitude: String(latitude),
                    longitude: String(longitude),
                    altitude: String(altitude)
                )
            }

            logger.info("⚽️ \(Self.self):\(#line) reverseGeolocation RESULT \(self.result)")
        } catch {
            logger.error("‼️ \(Self.self):\(#line) New location update error \(error)")
        }
    }
}
