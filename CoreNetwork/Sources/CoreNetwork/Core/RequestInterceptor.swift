//
//  RequestInterceptor.swift
//
//
//  Created by Marcos A. González Piñeiro on 02/01/2024.
//

import Foundation

/// Type that provides both `RequestAdapter` and `RequestRetrier` functionality.
public protocol RequestInterceptor: RequestAdapter, RequestRetrier {}

extension RequestInterceptor {
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        completion(.success(urlRequest))
    }

    public func retry(
        _ request: URLRequest,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        completion(.doNotRetry)
    }
}

/// Outcome of determination whether retry is necessary.
public enum RetryResult {
    /// Retry should be attempted immediately.
    case retry
    /// Retry should be attempted after the associated `TimeInterval`.
    case retryWithDelay(TimeInterval)
    /// Do not retry.
    case doNotRetry
    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(Error)
}

extension RetryResult {
    var retryRequired: Bool {
        switch self {
        case .retry, .retryWithDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }

    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}

/// Stores all state associated with a `URLRequest` being adapted.
public struct RequestAdapterState {
    /// The `UUID` of the `Request` associated with the `URLRequest` to adapt.
    public let requestID: UUID

    /// The `Session` associated with the `URLRequest` to adapt.
    public let session: Session
}

/// A type that can inspect and optionally adapt a `URLRequest` in some manner if necessary.
public protocol RequestAdapter {
    /// Inspects and adapts the specified `URLRequest` in some manner and calls the completion handler with the Result.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to adapt.
    ///   - session:    The `Session` that will execute the `URLRequest`.
    ///   - completion: The completion handler that must be called when adaptation is complete.
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    )

    /// Inspects and adapts the specified `URLRequest` in some manner and calls the completion handler with the Result.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to adapt.
    ///   - state:      The `RequestAdapterState` associated with the `URLRequest`.
    ///   - completion: The completion handler that must be called when adaptation is complete.
    func adapt(
        _ urlRequest: URLRequest,
        using state: RequestAdapterState,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    )
}

extension RequestAdapter {
    public func adapt(
        _ urlRequest: URLRequest,
        using state: RequestAdapterState,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        adapt(urlRequest, for: state.session, completion: completion)
    }
}

public protocol RequestRetrier {
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request:    `Request` that failed due to the provided `Error`.
    ///   - session:    `Session` that produced the `Request`.
    ///   - error:      `Error` encountered while executing the `Request`.
    ///   - completion: Completion closure to be executed when a retry decision has been determined.
    func retry(
        _ request: URLRequest,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    )
}

/// `RequestAdapter` closure definition.
public typealias AdaptHandler = (URLRequest, Session, _ completion: @escaping (Result<URLRequest, Error>) -> Void) -> Void
/// `RequestRetrier` closure definition.
public typealias RetryHandler = (URLRequest, Session, Error, _ completion: @escaping (RetryResult) -> Void) -> Void
