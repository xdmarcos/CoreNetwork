//
//  KnownErrors.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Foundation

public enum KnownErrors {

    enum ErrorCode: String {

        case unknown = "CoreNetwork.KnownErrors.ErrorCode.unknown"

        case decodingData = "CoreNetwork.KnownErrors.ErrorCode.decodingData"
        case encodingBody = "CoreNetwork.KnownErrors.ErrorCode.encodingBody"
        case forbidden = "CoreNetwork.KnownErrors.ErrorCode.forbiden"
        case invalidResponse = "CoreNetwork.KnownErrors.ErrorCode.invalidResponse"
        case unauthorized = "CoreNetwork.KnownErrors.ErrorCode.unauthorized"
        case urlComponents = "CoreNetwork.KnownErrors.ErrorCode.urlComponents"
        case statusCodeNotAllowed = "CoreNetwork.KnownErrors.ErrorCode.statusCodeNotAllowed"
        case mimeTypeNotValid = "CoreNetwork.KnownErrors.ErrorCode.mimeTypeNotValid"
        case responseContentDataUnavailable = "CoreNetwork.KnownErrors.ErrorCode.responseContentDataUnavailable"

        var code: String {
            switch self {
            case .unknown:
                return "ERROR-0"
            case .decodingData:
                return "ERROR-1"
            case .encodingBody:
                return "ERROR-2"
            case .invalidResponse:
                return "ERROR-4"
            case .urlComponents:
                return "ERROR-5"
            case .statusCodeNotAllowed:
                return "ERROR-6"
            case .mimeTypeNotValid:
                return "ERROR-7"
            case .responseContentDataUnavailable:
                return "ERROR-8"

            case .unauthorized:
                return "ERROR-401"
            case .forbidden:
                return "ERROR-403"
            }
        }

        var message: String {
            switch self {
            case .unknown:
                return "Unknown API error"
            case .decodingData:
                return "Decoding response data error"
            case .encodingBody:
                return "Encoding http body error"
            case .forbidden:
                return "Expired token error"
            case .unauthorized:
                return "Unauthorized error"
            case .invalidResponse:
                return "Invalid HTTP response error"
            case .urlComponents:
                return "Composing URL with components error"
            case .statusCodeNotAllowed:
                return "Response status code is not in allowed range"
            case .mimeTypeNotValid:
                return "Response mime type is not in expected list"
            case .responseContentDataUnavailable:
                return "Response content data is not available"
            }
        }
    }

    enum StatusCode: Int, CustomDebugStringConvertible {

        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case notAcceptable = 406
        case proxyAuthenticationRequired = 407
        case requestTimeout = 408

        case upgradeRequired = 426
        case tooManyRequests = 429

        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case httpVersionNotSupported = 505

        var debugDescription: String {
            switch self {
            case .badRequest:
                return "\(rawValue) Bad Request"
            case .unauthorized:
                return "\(rawValue) Unauthorized"
            case .forbidden:
                return "\(rawValue) Forbidden"
            case .notFound:
                return "\(rawValue) Not Found"
            case .methodNotAllowed:
                return "\(rawValue) Method Not Allowed"
            case .notAcceptable:
                return "\(rawValue) Not Acceptable"
            case .proxyAuthenticationRequired:
                return "\(rawValue) Proxy Authentication Required"
            case .requestTimeout:
                return "\(rawValue) Request Timeout"
            case .upgradeRequired:
                return "\(rawValue) Upgrade Required"
            case .tooManyRequests:
                return "\(rawValue) Too Many Requests"
            case .internalServerError:
                return "\(rawValue) Internal Server Error"
            case .notImplemented:
                return "\(rawValue) Not Implemented"
            case .badGateway:
                return "\(rawValue) Bad Gateway"
            case .serviceUnavailable:
                return "\(rawValue) Service Unavailable"
            case .gatewayTimeout:
                return "\(rawValue) Gateway Timeout"
            case .httpVersionNotSupported:
                return "\(rawValue) HTTP Version Not Supported"
            }
        }
    }
}
