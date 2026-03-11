//
//  WebDAVClient.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import Foundation

class WebDAVClient {
    private let baseURL: String
    private let username: String
    private let password: String

    init(serverURL: String, username: String, password: String) {
        // 确保 baseURL 结尾没有 /
        self.baseURL = serverURL.hasSuffix("/") ? String(serverURL.dropLast()) : serverURL
        self.username = username
        self.password = password
    }

    private func createRequest(path: String, method: String) -> URLRequest {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30.0

        // Basic Authentication
        let credentials = "\(username):\(password)"
        let credentialData = credentials.data(using: .utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "Depth")

        return request
    }

    // 列出文件
    func listFiles(path: String = "/") async throws -> [WebDAVFile] {
        let request = createRequest(path: path, method: "PROPFIND")

        print("📂 Listing files: \(baseURL)\(path)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 207 else {
            print("❌ WebDAV error: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            throw URLError(.badServerResponse)
        }

        // 解析 XML 响应
        let files = try parseWebDAVXML(data: data)
        print("✅ Found \(files.count) files")
        return files
    }

    // 下载文件（返回临时路径）
    func downloadFile(path: String) async throws -> URL {
        let request = createRequest(path: path, method: "GET")

        print("⬇️  Downloading: \(baseURL)\(path)")

        let (tempURL, response) = try await URLSession.shared.download(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Download failed")
            throw URLError(.badServerResponse)
        }

        // 移动到应用沙盒
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension((path as NSString).pathExtension)

        try FileManager.default.moveItem(at: tempURL, to: destination)

        print("✅ Downloaded to: \(destination.path)")
        return destination
    }

    private func parseWebDAVXML(data: Data) throws -> [WebDAVFile] {
        // 简化的 XML 解析 - 实际使用时需要完整的 DAV 解析
        // 这里返回一个示例文件列表，需要替换为实际的 WebDAV XML 解析

        // TODO: 实现完整的 WebDAV PROPFIND XML 解析
        // 参考: https://datatracker.ietf.org/doc/html/rfc4918

        let xmlString = String(data: data, encoding: .utf8) ?? ""
        print("📄 XML response length: \(data.count) bytes")

        // 临时返回空列表，需要实现完整解析
        return []
    }
}

struct WebDAVFile {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?

    static func sampleFiles() -> [WebDAVFile] {
        return [
            WebDAVFile(name: "Movies", path: "/Movies", isDirectory: true, size: nil),
            WebDAVFile(name: "Anime", path: "/Anime", isDirectory: true, size: nil),
            WebDAVFile(name: "Music", path: "/Music", isDirectory: true, size: nil),
        ]
    }
}
