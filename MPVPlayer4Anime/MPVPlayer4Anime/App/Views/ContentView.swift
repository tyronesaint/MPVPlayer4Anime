//
//  ContentView.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var webdavManager = WebDAVManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            WebDAVFileBrowser()
                .tabItem {
                    Label("文件", systemImage: "folder")
                }
                .tag(0)

            PlayerView()
                .tabItem {
                    Label("播放", systemImage: "play.rectangle")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(2)
        }
        .onReceive(NotificationCenter.default.publisher(for: .playVideo)) { notification in
            if let url = notification.userInfo?["url"] as? URL {
                selectedTab = 1
                // 通知播放器加载文件
                NotificationCenter.default.post(
                    name: .loadVideo,
                    object: nil,
                    userInfo: ["url": url]
                )
            }
        }
    }
}

extension Notification.Name {
    static let playVideo = Notification.Name("playVideo")
    static let loadVideo = Notification.Name("loadVideo")
}

#Preview {
    ContentView()
}
