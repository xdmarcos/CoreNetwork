//
//  ResponseOptions.swift
//
//
//  Created by Marcos A. González Piñeiro on 02/01/2024.
//

import Foundation

public protocol DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: DataDecoder {}

public protocol ResponseOptions {
    var decoder: DataDecoder { get }
    var successStatusCodeRange: ClosedRange<Int> { get }
    var mimeTypes: [CoreHTTPMimeType]? { get }
}

public struct ResponseOptionsImpl: ResponseOptions, CustomDebugStringConvertible {
    public let decoder: DataDecoder
    public let successStatusCodeRange: ClosedRange<Int>
    public let mimeTypes: [CoreHTTPMimeType]?

    public init(
        decoder: DataDecoder = JSONDecoder(),
        successStatusCodeRange: ClosedRange<Int> = CoreHTTPStatusCode.successRange,
        mimeTypes: [CoreHTTPMimeType]? = [CoreHTTPMimeType.json]
    ) {
        self.decoder = decoder
        self.successStatusCodeRange = successStatusCodeRange
        self.mimeTypes = mimeTypes
    }

    public var debugDescription: String {
        "decoder: \(decoder), successStatusCode: \(successStatusCodeRange.lowerBound) - \(successStatusCodeRange.upperBound), mimeTypes: \(mimeTypes ?? [])"
    }
}
