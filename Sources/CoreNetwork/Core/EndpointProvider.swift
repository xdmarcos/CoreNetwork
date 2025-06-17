//
//  EndpointProvider.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Foundation

public protocol EndpointProvider {

    var scheme: CoreHTTPScheme { get }
    var baseURL: String { get }
    var path: String { get }
    var method: CoreHTTPMethod { get }
    var authorization: CoreHTTPAuthorizationMethod? { get }
    var headers: [CoreHTTPHeaderKey: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: [String: Any]? { get }
    var mockFile: String? { get }
    var multipart: Multipart? { get }
}
