//
//  ApiError.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Foundation

public struct ApiError: Error, CustomDebugStringConvertible {

    let statusCode: Int
    let errorCode: String
    let message: String
    let originalError: Error?

    init(statusCode: Int = 0, errorCode: String, message: String, originalError: Error? = nil) {
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.message = message
        self.originalError = originalError
    }

    init(statusCode: Int = 0, apiError: ApiError, originalError: Error? = nil) {
        self.statusCode = statusCode
        self.errorCode = apiError.errorCode
        self.message = apiError.message
        self.originalError = originalError
    }

    init(statusCode: Int = 0, customError: KnownErrors.ErrorCode, originalError: Error? = nil) {
        self.statusCode = statusCode
        self.errorCode = customError.code
        self.message = customError.message
        self.originalError = originalError
    }

    var errorCodeNumber: String {
        let numberString = errorCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return numberString
    }

    public var debugDescription: String {
    """
        \(Self.self):
        - statusCode: \(statusCode)
        - errorCode: \(errorCode)
        - message: \(message)
        - originalError: \(String(describing: originalError?.localizedDescription))
    """
    }

    private enum CodingKeys: String, CodingKey {
        case errorCode
        case message
    }
}

extension ApiError: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = 0
        originalError = nil

        errorCode = try container.decode(String.self, forKey: .errorCode)
        message = try container.decode(String.self, forKey: .message)
    }
}
