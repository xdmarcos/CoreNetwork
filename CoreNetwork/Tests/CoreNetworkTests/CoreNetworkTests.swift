import XCTest
@testable import CoreNetwork

final class CoreNetworkTests: XCTestCase {
    private let sut: ApiClientProtocol = ApiClient()

    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testURLRequstGetHttpComponents() async throws {
        //Given
        let endpoint = Self.getHttpTestEndpoint
        let scheme  = endpoint.scheme.rawValue
        let baseURL = endpoint.baseURL
        let path = endpoint.path
        let method = endpoint.method.rawValue
        let queryItems = endpoint.queryItems

        //When
        let urlRequest = try endpoint.asURLRequest()

        //Then
        guard let url = urlRequest.url,
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("url is nil")
            return
        }

        XCTAssertEqual(urlRequest.httpMethod, method)

        XCTAssertEqual(urlComponents.scheme, scheme)
        XCTAssertEqual(urlComponents.host, baseURL)
        XCTAssertEqual(urlComponents.path, path)
        XCTAssertEqual(urlComponents.queryItems, queryItems)

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?.isEmpty, true)

        XCTAssertNil(urlRequest.httpBody)
    }

    func testURLRequstPostHttpsEndpointComponents() async throws {
        //Given
        let endpoint = Self.postHttpsTestEndpoint
        let scheme  = endpoint.scheme.rawValue
        let baseURL = endpoint.baseURL
        let path = endpoint.path
        let method = endpoint.method.rawValue
        let body = endpoint.body
        let authorization = endpoint.authorization

        //When
        let urlRequest = try endpoint.asURLRequest()

        //Then
        guard let url = urlRequest.url,
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("url is nil")
            return
        }

        guard let body = body else {
            XCTFail("body requiered for POST")
            return
        }

        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])

        XCTAssertEqual(urlRequest.httpMethod, method)
        XCTAssertEqual(urlComponents.scheme, scheme)
        XCTAssertEqual(urlComponents.host, baseURL)
        XCTAssertEqual(urlComponents.path, path)
        XCTAssertEqual(urlRequest.httpBody, bodyData)

        XCTAssertEqual(
            urlRequest.allHTTPHeaderFields, [
                CoreHTTPHeaderKey.accept.rawValue: "application/json",
                CoreHTTPHeaderKey.cacheControl.rawValue: "no-cache",
                CoreHTTPHeaderKey.authorization.rawValue: authorization!.value
            ]
        )

        XCTAssertNil(urlComponents.queryItems)
    }

    func testHttpGet_forwardQuery() async throws {
        //Given
        let endpoint = Self.forwardGeolocationEndpointProvider

        //When
        let geolocationInfo = try await sut.asyncRequest(endpoint: endpoint, responseModel: GeolocationTestModel.self)

        //Then
        XCTAssertTrue(geolocationInfo.data.count == 4)
        XCTAssertEqual(geolocationInfo.data.first?.countryModule.flag, "🇪🇸")
    }

    func testHttpGet_reverseQuery() async throws {
        //Given
        let endpoint = Self.reverseGeolocationEndpointProvider

        //When
        let geolocationInfo = try await sut.asyncRequest(endpoint: endpoint, responseModel: GeolocationTestModel.self)

        //Then
        XCTAssertEqual(geolocationInfo.data.first?.countryModule.flag, "🇪🇸")
    }
}

private extension CoreNetworkTests {
    struct EndpointProviderGetMock: EndpointProvider {
        var scheme: CoreNetwork.CoreHTTPScheme {
            .http
        }

        var baseURL: String {
            "get.baseurl.com"
        }

        var path: String {
            "/get_path"
        }

        var method: CoreNetwork.CoreHTTPMethod {
            .get
        }

        var queryItems: [URLQueryItem]? {
            [URLQueryItem(name: "query", value: "get_query_value")]
        }

        var authorization: CoreNetwork.CoreHTTPAuthorizationMethod? { nil }
        var headers: [CoreNetwork.CoreHTTPHeaderKey : String]? { nil }
        var body: [String : Any]? { nil }
        var mockFile: String? { nil }
    }

    struct EndpointProviderPostMock: EndpointProvider {
        var scheme: CoreNetwork.CoreHTTPScheme {
            .https
        }

        var baseURL: String {
            "post.baseurl.com"
        }

        var path: String {
            "/post_path"
        }

        var method: CoreNetwork.CoreHTTPMethod {
            .post
        }

        var body: [String: Any]? {
            ["bodyParam": "post_body_value"]
        }

        var authorization: CoreNetwork.CoreHTTPAuthorizationMethod? { 
            .bearer(token: "bearer.token.test")
        }

        var headers: [CoreNetwork.CoreHTTPHeaderKey : String]? {
            [
                .accept: "application/json",
                .cacheControl: "no-cache"
            ]
        }

        var queryItems: [URLQueryItem]? { nil }
        var mockFile: String? { nil }
    }

    enum EndpointProviderGeolocationMock: EndpointProvider {
        case forwardGeolocation(address: String)
        case reverseGeolocation(lat: String, lon: String)

        var scheme: CoreNetwork.CoreHTTPScheme { .http }

        var baseURL: String { "api.positionstack.com" }

        var path: String {
            switch self {
            case .forwardGeolocation:
                return "/v1/forward"
            case .reverseGeolocation:
                return "/v1/reverse"
            }
        }

        var method: CoreNetwork.CoreHTTPMethod { .get }
        var queryItems: [URLQueryItem]? {
            switch self {
            case let .forwardGeolocation(address):
                return [
                    URLQueryItem(name: "access_key", value: "ce0734ed76325a335304403835d29b41"),
                    URLQueryItem(name: "query", value: address),
                    URLQueryItem(name: "country_module", value: "1")
                ]
            case let .reverseGeolocation(lat, lon):
                return [
                    URLQueryItem(name: "access_key", value: "ce0734ed76325a335304403835d29b41"),
                    URLQueryItem(name: "query", value: "\(lat),\(lon)"),
                    URLQueryItem(name: "country_module", value: "1")
                ]
            }
        }

        var authorization: CoreNetwork.CoreHTTPAuthorizationMethod? { nil }
        var headers: [CoreNetwork.CoreHTTPHeaderKey : String]? { nil }
        var body: [String : Any]? { nil }
        var mockFile: String? { nil }
    }

    static let getHttpTestEndpoint = EndpointProviderGetMock()
    static let postHttpsTestEndpoint = EndpointProviderPostMock()
    static let forwardGeolocationEndpointProvider: EndpointProviderGeolocationMock = .forwardGeolocation(address: "Porriño")
    static let reverseGeolocationEndpointProvider: EndpointProviderGeolocationMock = .reverseGeolocation(lat: "42.161434", lon: "-8.619662")
}
