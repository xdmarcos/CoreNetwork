//
//  GeolocationViewModel.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 20/12/2023.
//

import Foundation
import CoreLocation

struct Country: Equatable {
    let name: String
    let flag: CLLocation
}

struct GeolocationViewModel: Equatable {
    let address: String
    let location: CLLocation
    let result: [Country]

    init(address: String, location: CLLocation, result: [Country]) {
        self.address = address
        self.location = location
        self.result = result
    }
}
