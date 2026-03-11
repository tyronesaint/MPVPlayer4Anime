//
//  WebDAVManager.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import Foundation

class WebDAVManager: ObservableObject {
    static let shared = WebDAVManager()

    private let defaults = UserDefaults.standard

    struct Server: Codable, Identifiable {
        let id: UUID
        let name: String
        let url: String
        let username: String
        let password: String
    }

    @Published var servers: [Server] {
        didSet {
            saveServers()
        }
    }

    private init() {
        servers = loadServers()
    }

    private func loadServers() -> [Server] {
        guard let data = defaults.data(forKey: "webdav_servers") else {
            return []
        }
        do {
            return try JSONDecoder().decode([Server].self, from: data)
        } catch {
            print("❌ Failed to load WebDAV servers: \(error)")
            return []
        }
    }

    private func saveServers() {
        do {
            let data = try JSONEncoder().encode(servers)
            defaults.set(data, forKey: "webdav_servers")
        } catch {
            print("❌ Failed to save WebDAV servers: \(error)")
        }
    }

    func addServer(name: String, url: String, username: String, password: String) {
        let server = Server(
            id: UUID(),
            name: name,
            url: url,
            username: username,
            password: password
        )
        servers.append(server)
        print("✅ Added server: \(name)")
    }

    func deleteServer(id: UUID) {
        servers.removeAll { $0.id == id }
        print("🗑️  Deleted server")
    }

    func getServer(id: UUID) -> Server? {
        return servers.first { $0.id == id }
    }
}
