//
//  Multipart.swift
//
//
//  Created by Marcos A. González Piñeiro on 08/01/2024.
//

import Foundation

public struct Multipart {

    private var data =  NSMutableData()

    private let boundary: String = UUID().uuidString
    private let separator: String = "\r\n"

    private var topBoundry: String {
        return "--\(boundary)"
    }

    private var endBoundry: String {
        return "--\(boundary)--"
    }

    private func contentDisposition(_ name: String, fileName: String?) -> String {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName { disposition += "; filename=\"\(fileName)\"" }
        return "\(CoreHTTPHeaderKey.contentDisposition): " + disposition
    }

    var headerValue: String {
        "\(CoreHTTPMimeType.multipart.rawValue); boundary=\(boundary)"
    }

    var httpBody: Data {
        let bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData as Data
    }

    var length: UInt64 {
        return UInt64(httpBody.count)
    }

    func append(fileString: String, withName name: String) {
        data.append(topBoundry)
        data.append(separator)
        data.append(contentDisposition(name, fileName: nil))
        data.append(separator)
        data.append(separator)
        data.append(fileString)
        data.append(separator)
    }

    func append(fileData: Data, withName name: String, fileName: String?, mimeType: CoreHTTPMimeType?) {
        data.append(topBoundry)
        data.append(separator)
        data.append(contentDisposition(name, fileName: fileName))
        data.append(separator)
        if let mimeType = mimeType {
            data.append("\(CoreHTTPHeaderKey.contentType.rawValue): \(mimeType.rawValue)" + separator)
        }
        data.append(separator)
        data.append(fileData)
        data.append(separator)
    }

    func append(fileURL: URL, withName name: String) {
        guard let fileData = try? Data(contentsOf: fileURL) else {
            return
        }
        let fileName = fileURL.lastPathComponent
        let pathExtension = fileURL.pathExtension
        let mimeType = mimeType(for: pathExtension)

        data.append(topBoundry)
        data.append(separator)
        data.append(contentDisposition(name, fileName: fileName))
        data.append(separator)
        data.append("\(CoreHTTPHeaderKey.contentType.rawValue): \(mimeType)" + separator)
        data.append(separator)
        data.append(fileData)
        data.append(separator)
    }

}

import UniformTypeIdentifiers

extension Multipart {
    private func mimeType(for pathExtension: String) -> String {
        UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "\(CoreHTTPMimeType.anyBinary.rawValue)"
    }
}

extension NSMutableData {
    func append(_ string: String, encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            self.append(data)
        }
    }
}
