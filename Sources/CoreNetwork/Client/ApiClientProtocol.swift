//
//  ApiClientProtocol.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Combine
import Foundation

public protocol ApiClientProtocol {
    var session: Session { get }

    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T
    func asyncRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions
    ) async throws -> T

    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, ApiError>
    func combineRequest<T: Decodable>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions
    ) -> AnyPublisher<T, ApiError>
}
