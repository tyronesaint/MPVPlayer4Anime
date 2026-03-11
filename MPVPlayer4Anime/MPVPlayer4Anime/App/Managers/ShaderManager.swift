//
//  ShaderManager.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import Foundation

class ShaderManager {
    static let shared = ShaderManager()

    private let shaderDirectory: URL

    private init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        shaderDirectory = paths[0].appendingPathComponent("Shaders")

        // 创建目录
        try? FileManager.default.createDirectory(at: shaderDirectory, withIntermediateDirectories: true)

        print("📁 Shader directory: \(shaderDirectory.path)")
    }

    // 拷贝内置 shaders 到文档目录
    func copyBuiltinShaders() {
        guard let bundleShaders = Bundle.main.url(forResource: "Shaders", withExtension: nil) else {
            print("⚠️  Built-in shaders not found in bundle")
            return
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(at: bundleShaders, includingPropertiesForKeys: nil)
            var copiedCount = 0

            for file in files where file.pathExtension == "glsl" {
                let destination = shaderDirectory.appendingPathComponent(file.lastPathComponent)
                if !FileManager.default.fileExists(atPath: destination.path) {
                    try? FileManager.default.copyItem(at: file, to: destination)
                    copiedCount += 1
                }
            }

            print("✅ Copied \(copiedCount) shaders to: \(shaderDirectory.path)")
        } catch {
            print("❌ Failed to copy shaders: \(error)")
        }
    }

    // 获取 shader 路径
    func getShaderPath(named name: String) -> String? {
        let path = shaderDirectory.appendingPathComponent("\(name).glsl")
        return FileManager.default.fileExists(atPath: path.path) ? path.path : nil
    }

    // 列出可用 shaders
    func listAvailableShaders() -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: shaderDirectory, includingPropertiesForKeys: nil)
            return files
                .filter { $0.pathExtension == "glsl" }
                .map { $0.deletingPathExtension().lastPathComponent }
                .sorted()
        } catch {
            print("❌ Failed to list shaders: \(error)")
            return []
        }
    }

    // 删除 shader
    func deleteShader(named name: String) {
        let path = shaderDirectory.appendingPathComponent("\(name).glsl")
        try? FileManager.default.removeItem(at: path)
        print("🗑️  Deleted shader: \(name)")
    }
}
