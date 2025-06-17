//
//  RequestOptions.swift
//
//
//  Created by Marcos A. González Piñeiro on 02/01/2024.
//

import Foundation

public protocol DataEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: DataEncoder {}

public extension Encodable {
    func toDictionary(encoder: DataEncoder) -> [String: Any]? {
        guard let data = try? encoder.encode(self) else { return nil }
        return jsonObject(data: data)
    }

    var toDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return jsonObject(data: data)
    }

    private func jsonObject(data: Data) -> [String: Any]? {
        (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

public protocol RequestOptions {
    var encoder: DataEncoder? { get }
    var mimeType: CoreHTTPMimeType? { get }
}

public struct RequestOptionsImpl: RequestOptions, CustomDebugStringConvertible {

    public let encoder: DataEncoder?
    public let mimeType: CoreHTTPMimeType?

    public init(
        encoder: DataEncoder? = JSONEncoder(),
        mimeType: CoreHTTPMimeType? = CoreHTTPMimeType.json
    ) {
        self.encoder = encoder
        self.mimeType = mimeType
    }

    public var debugDescription: String {
        "encoder: \(String(describing: encoder)), acceptMimeType: \(mimeType?.rawValue ?? "nil")"
    }
}
