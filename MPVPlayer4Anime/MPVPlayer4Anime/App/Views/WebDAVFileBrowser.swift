//
//  WebDAVFileBrowser.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import SwiftUI

struct WebDAVFileBrowser: View {
    @State private var currentPath = "/"
    @State private var files: [WebDAVFile] = []
    @State private var isLoading = false
    @State private var selectedServer: WebDAVManager.Server?
    @State private var showingServerPicker = false
    @State private var showingAddServer = false
    @StateObject private var webdavManager = WebDAVManager.shared

    var body: some View {
        NavigationView {
            List {
                // 服务器选择器
                Section {
                    Button(action: { showingServerPicker = true }) {
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.blue)
                            Text(selectedServer?.name ?? "选择 WebDAV 服务器")
                                .foregroundColor(selectedServer == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }

                    // 添加服务器按钮
                    Button(action: { showingAddServer = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("添加服务器")
                        }
                    }
                } header: {
                    Text("WebDAV 服务器")
                }

                // 文件列表
                Section {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("加载中...")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    } else if files.isEmpty {
                        HStack {
                            Spacer()
                            Text("暂无文件")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        // 返回上级目录
                        if currentPath != "/" {
                            Button(action: { navigateToParent() }) {
                                HStack {
                                    Image(systemName: "chevron.up")
                                        .foregroundColor(.gray)
                                    Text("..")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }

                        // 文件和目录列表
                        ForEach(files, id: \.path) { file in
                            if file.isDirectory {
                                Button(action: { navigateToDirectory(file.path) }) {
                                    FileRow(file: file, isDirectory: true)
                                }
                            } else {
                                Button(action: { playFile(file) }) {
                                    FileRow(file: file, isDirectory: false)
                                }
                            }
                        }
                    }
                } header: {
                    if selectedServer != nil {
                        Text("文件")
                    }
                }
            }
            .navigationTitle("WebDAV 文件")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { loadFiles() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(selectedServer == nil)
                }
            }
            .sheet(isPresented: $showingServerPicker) {
                ServerPickerSheet(
                    servers: webdavManager.servers,
                    selectedServer: $selectedServer,
                    onDeleteServer: { id in
                        webdavManager.deleteServer(id: id)
                        if selectedServer?.id == id {
                            selectedServer = nil
                            files = []
                        }
                    }
                )
            }
            .sheet(isPresented: $showingAddServer) {
                AddServerSheet(
                    onAdd: { name, url, username, password in
                        webdavManager.addServer(name: name, url: url, username: username, password: password)
                    }
                )
            }
        }
        .onChange(of: selectedServer) { _ in
            if selectedServer != nil {
                currentPath = "/"
                loadFiles()
            }
        }
    }

    private func loadFiles() {
        guard let server = selectedServer else { return }

        isLoading = true
        let client = WebDAVClient(
            serverURL: server.url,
            username: server.username,
            password: server.password
        )

        Task {
            do {
                files = try await client.listFiles(path: currentPath)
                isLoading = false
            } catch {
                print("❌ Failed to load files: \(error)")
                // 显示错误提示
                isLoading = false
                files = []
            }
        }
    }

    private func navigateToDirectory(_ path: String) {
        currentPath = path
        loadFiles()
    }

    private func navigateToParent() {
        currentPath = (currentPath as NSString).deletingLastPathComponent
        if currentPath.isEmpty { currentPath = "/" }
        loadFiles()
    }

    private func playFile(_ file: WebDAVFile) {
        guard let server = selectedServer else { return }

        isLoading = true
        let client = WebDAVClient(
            serverURL: server.url,
            username: server.username,
            password: server.password
        )

        Task {
            do {
                let localURL = try await client.downloadFile(path: file.path)
                isLoading = false

                // 播放文件
                NotificationCenter.default.post(
                    name: .playVideo,
                    object: nil,
                    userInfo: ["url": localURL]
                )

                print("✅ Playing: \(file.name)")
            } catch {
                print("❌ Failed to download file: \(error)")
                isLoading = false
            }
        }
    }
}

struct FileRow: View {
    let file: WebDAVFile
    let isDirectory: Bool

    var body: some View {
        HStack {
            Image(systemName: isDirectory ? "folder.fill" : "play.circle.fill")
                .foregroundColor(isDirectory ? .blue : .green)
                .frame(width: 30)

            Text(file.name)
                .lineLimit(1)

            if !isDirectory, let size = file.size {
                Spacer()
                Text(formatBytes(size))
                    .foregroundColor(.gray)
                    .font(.caption)
            } else {
                Spacer()
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct ServerPickerSheet: View {
    let servers: [WebDAVManager.Server]
    @Binding var selectedServer: WebDAVManager.Server?
    let onDeleteServer: (UUID) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(servers) { server in
                    Button(action: {
                        selectedServer = server
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(server.name)
                                    .font(.headline)
                                Text(server.url)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if selectedServer?.id == server.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        onDeleteServer(servers[index].id)
                    }
                }
            }
            .navigationTitle("选择服务器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddServerSheet: View {
    @State private var name = ""
    @State private var url = ""
    @State private var username = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    let onAdd: (String, String, String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("服务器信息")) {
                    TextField("名称", text: $name)
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("用户名", text: $username)
                        .autocapitalization(.none)
                    SecureField("密码", text: $password)
                }
            }
            .navigationTitle("添加服务器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        onAdd(name, url, username, password)
                        dismiss()
                    }
                    .disabled(name.isEmpty || url.isEmpty)
                }
            }
        }
    }
}

#Preview {
    WebDAVFileBrowser()
}
