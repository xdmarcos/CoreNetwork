//
//  ApiClient.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Combine
import Foundation

open class ApiClient: ApiClientProtocol {

    public let session: Session

    public init(session: Session = SessionImpl.shared) {
        self.session = session
    }

    open func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T {
        try await asyncRequest(
            endpoint: endpoint,
            responseModel: responseModel,
            requestOptions: RequestOptionsImpl(),
            responseOptions: ResponseOptionsImpl()
        )
    }

    open func asyncRequest<T>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions
    ) async throws -> T where T : Decodable {
        do {
            var request = try endpoint.asURLRequest()
            update(request: &request, options: requestOptions)
            logRequest(request: request, with: requestOptions)

            let (data, response) = try await session.data(for: request)

            logResponse(response: response, data: data, with: responseOptions)
            try validate(response: response, with: responseOptions)
            let decoded: T = try decodeResponse(data: data)
            logDecodedResponse(data: decoded)
            return decoded
        } catch let error as ApiError {
            debugPrint("‼️", error)
            if error.errorCode == KnownErrors.ErrorCode.unauthorized.rawValue ||
                error.errorCode == KnownErrors.ErrorCode.forbidden.rawValue {
                //retry/adapt expired token
            }
            
            throw error
        } catch {
            debugPrint("‼️", error)
            throw ApiError(customError: .unknown, originalError: error)
        }
    }

    open func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, ApiError> {
        combineRequest(
            endpoint: endpoint,
            responseModel: responseModel,
            requestOptions: RequestOptionsImpl(),
            responseOptions: ResponseOptionsImpl()
        )
    }

    open func combineRequest<T>(
        endpoint: EndpointProvider,
        responseModel: T.Type,
        requestOptions: RequestOptions,
        responseOptions: ResponseOptions
    ) -> AnyPublisher<T, ApiError> where T : Decodable {
        do {
            var request = try endpoint.asURLRequest()
            update(request: &request, options: requestOptions)
            logRequest(request: request, with: requestOptions)

            return session
                .dataTaskPublisher(for: request)
                .tryMap { output in
                    self.logResponse(response: output.response, data: output.data, with: responseOptions)
                    try self.validate(response: output.response, with: responseOptions)

                    let decoded: T = try self.decodeResponse(data: output.data)
                    self.logDecodedResponse(data: decoded)
                    return decoded
                }
                .mapError {
                    debugPrint("‼️", $0)
                    return $0 as? ApiError ?? ApiError(customError: .unknown, originalError: $0)
                }
                .eraseToAnyPublisher()
        } catch let error as ApiError {
            debugPrint("‼️", error)
            return AnyPublisher<T, ApiError>(Fail(error: error))
        } catch {
            debugPrint("‼️", error)
            return AnyPublisher<T, ApiError>(
                Fail(error: ApiError(customError: .unknown, originalError: error))
            )
        }
    }

    open func update(request: inout URLRequest, options: RequestOptions) {
        request.addAcceptMIMEType(mime: options.mimeType)
    }

    open func validate(response: URLResponse?, with options: ResponseOptions) throws {
        try validate(response: response, statusCodes: options.successStatusCodeRange)
        try validate(response: response, mimeTypes: options.mimeTypes)
    }
}

private extension ApiClient {
    func validate(response: URLResponse?, statusCodes: ClosedRange<Int>?) throws {
        guard let allowlist = statusCodes else { return }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError(customError: .invalidResponse)
        }

        if !allowlist.contains(httpResponse.statusCode) {
            var error = ApiError(statusCode: httpResponse.statusCode, customError: .statusCodeNotAllowed)
            if httpResponse.statusCode == KnownErrors.StatusCode.unauthorized.rawValue {
                error = ApiError(statusCode: httpResponse.statusCode, customError: .unauthorized)
            }

            if httpResponse.statusCode == KnownErrors.StatusCode.forbidden.rawValue {
                error = ApiError(statusCode: httpResponse.statusCode, customError: .forbidden)
            }

            throw error
        }
    }

    func validate(response: URLResponse?, mimeTypes: [CoreHTTPMimeType]?) throws {
        guard let allowlist = mimeTypes else { return }

        guard let mimeTypeResponse = response?.mimeType else {
            throw ApiError(customError: .invalidResponse)
        }

        let found = !allowlist.filter { $0.rawValue == mimeTypeResponse }.isEmpty
        guard found else {
            throw ApiError(customError: .mimeTypeNotValid)
        }
    }

    func decodeResponse<T: Decodable>(data: Data) throws -> T {
        guard !data.isEmpty else {
            throw ApiError(customError: .responseContentDataUnavailable)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ApiError(customError: .decodingData, originalError: error)
        }
    }

    func logRequest(request: URLRequest, with options: RequestOptions) {
        debugPrint("🛜 \(Self.self) Request info:")
        debugPrint("⬆️ options: \(options)")
        debugPrint("⬆️ method: \(request.httpMethod ?? "")")
        debugPrint("⬆️ url: \(request.url?.absoluteString ?? "")")
        debugPrint("⬆️ headers: \(request.allHTTPHeaderFields ?? [:])")
        debugPrint("⬆️ body: \(request.httpBody?.jsonObject ?? [:])")
        debugPrint("⬆️ END Request info")
    }

    func logResponse(response: URLResponse?, data: Data, with options: ResponseOptions) {
        debugPrint("🛜 \(Self.self) Response info:")
        debugPrint("⬇️ options: \(options)")
        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("⬇️ description not valid")
            return
        }
        debugPrint("⬇️ status code: \(httpResponse.statusCode)")
        debugPrint("⬇️ MIME type: \(httpResponse.mimeType ?? "")")
        debugPrint("⬇️ Body: \(data.jsonString ?? "")")
        debugPrint("⬇️ END Response info")
    }

    func logDecodedResponse<T: Decodable>(data: T) {
        debugPrint("🛜 \(Self.self) Decoded Response:")
        debugPrint("📨 description: \(data) \n")
        debugPrint("📨 END Decoded Response")
    }
}

private extension URLRequest {
    mutating func addAcceptMIMEType(mime: CoreHTTPMimeType?) {
        guard let value = mime?.rawValue, !value.isEmpty else { return }
        addValue(value, forHTTPHeaderField: CoreHTTP.HeaderKey.accept.rawValue)
    }
}

private extension Data {
    var jsonObject: [String: Any]? {
        (try? JSONSerialization.jsonObject(with: self, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    var jsonString: String? { String(data: self, encoding: .utf8) }
}
