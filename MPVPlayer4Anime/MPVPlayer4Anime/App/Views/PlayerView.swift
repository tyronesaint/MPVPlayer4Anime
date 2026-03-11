//
//  PlayerView.swift
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    @State private var isPlaying = false
    @State private var selectedShader: String?
    @State private var showControls = true
    @State private var currentURL: URL?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                // 播放器视图
                if currentURL != nil {
                    MpvPlayerUIView(
                        url: currentURL,
                        isPlaying: $isPlaying,
                        shader: $selectedShader
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "play.rectangle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("请先选择视频文件")
                            .foregroundColor(.gray)
                            .padding(.top)
                        Spacer()
                    }
                }

                // 控制层
                if showControls {
                    VStack {
                        Spacer()

                        VStack(spacing: 20) {
                            // 播放控制
                            HStack(spacing: 40) {
                                Button(action: {
                                    // 暂停功能
                                    isPlaying.toggle()
                                }) {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }

                                Button(action: {
                                    // 停止功能
                                    currentURL = nil
                                    isPlaying = false
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }
                            }

                            // Shader 选择
                            Menu {
                                ForEach(ShaderManager.shared.listAvailableShaders(), id: \.self) { shader in
                                    Button(shader) {
                                        selectedShader = shader
                                        print("🎨 Selected shader: \(shader)")
                                    }
                                }
                                if ShaderManager.shared.listAvailableShaders().isEmpty {
                                    Button("无可用 Shaders", action: {})
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "paintbrush.fill")
                                    Text(selectedShader ?? "选择 Anime4K Shader")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                    }
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    showControls.toggle()
                }
            }
        }
        .onAppear {
            ShaderManager.shared.copyBuiltinShaders()
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadVideo)) { notification in
            if let url = notification.userInfo?["url"] as? URL {
                currentURL = url
                isPlaying = true
                print("📽️  Loading video: \(url.lastPathComponent)")
            }
        }
    }
}

struct MpvPlayerUIView: UIViewRepresentable {
    let url: URL?
    @Binding var isPlaying: Bool
    @Binding var shader: String?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let url = url else { return }

        if context.coordinator.playerWrapper == nil {
            context.coordinator.setupPlayer(view: uiView, url: url, shader: shader)
        }

        context.coordinator.updatePlaybackState(isPlaying: isPlaying)

        if let shader = shader,
           let shaderPath = ShaderManager.shared.getShaderPath(named: shader) {
            context.coordinator.setShader(shaderPath)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        private var playerWrapper: MPVPlayerWrapper?

        func setupPlayer(view: UIView, url: URL?, shader: String?) {
            playerWrapper = MPVPlayerWrapper(view: view)

            if let url = url {
                playerWrapper?.loadFile(url.path)
                playerWrapper?.play()
            }

            if let shader = shader,
               let shaderPath = ShaderManager.shared.getShaderPath(named: shader) {
                playerWrapper?.setShader(shaderPath)
            }
        }

        func updatePlaybackState(isPlaying: Bool) {
            if isPlaying {
                playerWrapper?.play()
            } else {
                playerWrapper?.pause()
            }
        }

        func setShader(_ path: String) {
            playerWrapper?.setShader(path)
        }
    }
}

#Preview {
    PlayerView()
}
