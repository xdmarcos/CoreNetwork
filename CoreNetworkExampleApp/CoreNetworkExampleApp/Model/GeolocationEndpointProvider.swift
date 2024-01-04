//
//  GeolocationEndpointProvider.swift
//  CoreNetworkExampleApp
//
//  Created by Marcos A. González Piñeiro on 03/01/2024.
//

import Foundation
import CoreNetwork

enum GeolocationEndpointProvider: EndpointProvider {
    case forwardGeolocation(address: String)
    case reverseGeolocation(lat: String, lon: String)

    var scheme: CoreNetwork.CoreHTTPScheme { .http }

    var baseURL: String { "api.positionstack.com" }

    var path: String {
        switch self {
        case .forwardGeolocation:
            return "/v1/forward"
        case .reverseGeolocation:
            return "/v1/reverse"
        }
    }

    var method: CoreNetwork.CoreHTTPMethod { .get }
    var queryItems: [URLQueryItem]? {
        switch self {
        case let .forwardGeolocation(address):
            return [
                URLQueryItem(name: "access_key", value: "ce0734ed76325a335304403835d29b41"),
                URLQueryItem(name: "query", value: address),
                URLQueryItem(name: "country_module", value: "1")
            ]
        case let .reverseGeolocation(lat, lon):
            return [
                URLQueryItem(name: "access_key", value: "ce0734ed76325a335304403835d29b41"),
                URLQueryItem(name: "query", value: "\(lat),\(lon)"),
                URLQueryItem(name: "country_module", value: "1")
            ]
        }
    }

    var authorization: CoreNetwork.CoreHTTPAuthorizationMethod? { nil }
    var headers: [CoreNetwork.CoreHTTPHeaderKey : String]? { nil }
    var body: [String : Any]? { nil }
    var mockFile: String? { nil }
}
