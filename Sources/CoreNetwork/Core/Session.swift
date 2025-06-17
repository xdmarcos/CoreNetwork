//
//  Session.swift
//  
//
//  Created by Marcos A. González Piñeiro on 02/01/2024.
//

import Foundation

public protocol Session {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}


public final class SessionImpl: Session, Sendable {
    public static let shared = SessionImpl()

    public static let defaultConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60 // seconds that a task will wait for data to arrive
        configuration.timeoutIntervalForResource = 300 // seconds for whole resource request to complete
        return configuration
    }()

    public let session: URLSession

    public init(configuration: URLSessionConfiguration = defaultConfiguration) {
        self.session = URLSession(configuration: configuration)
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
    
    public func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        session.dataTaskPublisher(for: request)
    }
}
