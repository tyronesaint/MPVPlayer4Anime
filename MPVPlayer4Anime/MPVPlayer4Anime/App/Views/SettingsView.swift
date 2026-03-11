//
//  SettingsView.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var webdavManager = WebDAVManager.shared

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MPVPlayer4Anime")
                                .font(.headline)
                            Text("版本 1.0.0")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                } header: {
                    Text("关于")
                }

                Section {
                    NavigationLink(destination: ServerManagementView()) {
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.purple)
                            Text("WebDAV 服务器")
                            Spacer()
                            Text("\(webdavManager.servers.count) 个")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }

                    NavigationLink(destination: ShaderManagementView()) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.orange)
                            Text("Anime4K Shaders")
                            Spacer()
                            Text("\(ShaderManager.shared.listAvailableShaders().count) 个")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("配置")
                }

                Section {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("支持特性")
                                .font(.headline)
                            Text("• 基于 libmpv 核心")
                                .font(.caption)
                            Text("• Metal 硬件加速")
                                .font(.caption)
                            Text("• Anime4K 渲染")
                                .font(.caption)
                            Text("• WebDAV 远程播放")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                } header: {
                    Text("功能")
                }
            }
            .navigationTitle("设置")
        }
    }
}

struct ServerManagementView: View {
    @StateObject private var webdavManager = WebDAVManager.shared

    var body: some View {
        List {
            if webdavManager.servers.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("暂无服务器")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 40)
                    Spacer()
                }
            } else {
                ForEach(webdavManager.servers) { server in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(server.name)
                            .font(.headline)
                        Text(server.url)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("用户: \(server.username)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        webdavManager.deleteServer(id: webdavManager.servers[index].id)
                    }
                }
            }
        }
        .navigationTitle("WebDAV 服务器")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !webdavManager.servers.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

struct ShaderManagementView: View {
    @State private var shaders: [String] = []

    var body: some View {
        List {
            if shaders.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "paintbrush")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("暂无 Shaders")
                            .foregroundColor(.gray)
                        Text("请将 .glsl 文件放入应用文档目录的 Shaders 文件夹")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            } else {
                ForEach(shaders, id: \.self) { shader in
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.orange)
                        Text(shader)
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        ShaderManager.shared.deleteShader(named: shaders[index])
                        loadShaders()
                    }
                }
            }
        }
        .navigationTitle("Anime4K Shaders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !shaders.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("刷新") {
                    loadShaders()
                }
            }
        }
        .onAppear {
            loadShaders()
        }
    }

    private func loadShaders() {
        shaders = ShaderManager.shared.listAvailableShaders()
    }
}

#Preview {
    SettingsView()
}
