//
//  CoreHTTP.swift
//
//
//  Created by Marcos A. González Piñeiro on 19/12/2023.
//

import Foundation

public enum CoreHTTP {
    public enum StatusCode {
        public static let successRange: ClosedRange<Int> = 200...299
    }

    public enum Scheme: String {

        case http = "http"
        case https = "https"
    }

    public enum Method: String {

        case delete = "DELETE"
        case connect = "CONNECT"
        case get = "GET"
        case head = "HEAD"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
    }

    public enum HeaderKey: String {

        case accept = "Accept"
        case acceptCharset = "Accept-Charset"
        case acceptDatetime = "Accept-Datetime"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case authorization = "Authorization"

        case cacheControl = "Cache-Control"
        case connection = "Connection"
        case contentLength = "Content-Length"
        case contentType = "Content-Type"
        case contentDisposition = "Content-Disposition"
        case cookie = "Cookie"

        case host = "Host"

        case proxyAuthorization = "Proxy-Authorization"

        case userAgent = "User-Agent"
    }

    public enum MimeType: String {
        case any = "*/*"
        case anyImage = "image/*"

        case json = "application/json"
        case anyBinary = "application/octet-stream"
        case urlEncoded = "application/x-www-form-urlencoded"

        case plain = "text/plain"
        case javascript = "text/javascript"
        case html = "text/html"
        case css = "text/css"

        case gif = "image/gif"
        case png = "image/png"
        case jpg = "image/jpg"
        case jpeg = "image/jpeg"
        case svg = "image/svg"
        case tiff = "image/tiff"
        case bmp = "image/bmp"
        case quickTime = "video/quicktime"
        case mov = "video/mov"
        case mp4 = "video/mp4"
        case pdf = "application/pdf"
        case vnd = "application/vnd"

        case multipart = "multipart/form-data"
    }

    public enum AuthorizationMethod {

        case basic(token: String)
        case bearer(token: String)
        case digest(token: String)
        case aws(token: String)

        var value: String {
            switch self {
            case let .basic(token):
                return "\(type) \(token)"
            case let .bearer(token):
                return "\(type) \(token)"
            case let .digest(token):
                return "\(type) \(token)"
            case let .aws(token):
                return "\(type) \(token)"
            }
        }

        var type: String {
            switch self {
            case .basic:
                return "Basic"
            case .bearer:
                return "Bearer"
            case .digest:
                return "Digest"
            case .aws:
                return "AWS4-HMAC-SHA256"
            }
        }
    }
}
