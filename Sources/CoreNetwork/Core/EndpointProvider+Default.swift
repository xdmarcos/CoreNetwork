//
//  EndpointProvider+Basic.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Foundation

extension EndpointProvider {

    func asURLRequest() throws -> URLRequest {

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme.rawValue
        urlComponents.host =  baseURL
        urlComponents.path = path
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        guard let url = urlComponents.url else {
            throw ApiError(customError: .urlComponents)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if let customHeaders = headers {
            let mappedHeaders: [String: String] = customHeaders.reduce([:]) { partial, current in
                var next = partial
                next[current.key.rawValue] = current.value
                return next
            }

            urlRequest.allHTTPHeaderFields = mappedHeaders
        }

        if let authorization = authorization {
            urlRequest.addValue(authorization.value, forHTTPHeaderField: CoreHTTP.HeaderKey.authorization.rawValue)
        }

        if let multipart = multipart {
            urlRequest.setValue(multipart.headerValue, forHTTPHeaderField: CoreHTTPHeaderKey.contentType.rawValue)
            urlRequest.setValue("\(multipart.length)", forHTTPHeaderField: CoreHTTPHeaderKey.contentLength.rawValue)
            urlRequest.httpBody = multipart.httpBody
        }

        if let body = body {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw ApiError(customError: .encodingBody)
            }
        }

        return urlRequest
    }
}
