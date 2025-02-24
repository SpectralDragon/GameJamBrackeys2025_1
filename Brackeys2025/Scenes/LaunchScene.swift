//
//  LaunchScene.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

class LaunchScene: AdaEngine.Scene {
    private(set) var font: Font!
    
    override func sceneDidMove(to view: SceneView) {
        let camera = OrthographicCamera()
        camera.camera.orthographicScale = 4
        camera.camera.backgroundColor = .black
        camera.components[Transform.self]?.position.y = 0.8
        self.addEntity(camera)
        
        Game.isPaused = false
        
        Task { @MainActor in
            do {
                try await setupScene()
            } catch {
                Application.shared.showAlert(
                    Alert(
                        title: "Error!",
                        message: error.localizedDescription,
                        buttons: [
                            .button("Ok", action: {
                                Application.shared.terminate()
                            })
                        ]
                    )
                )
            }
        }
    }
    
    deinit {
        #if DEBUG
        print("Deinited MainScene")
        #endif
    }
}

private extension LaunchScene {
    @MainActor
    func setupScene() async throws {
        let fontRes = try await ResourceManager.load("PixelSmall.ttf", from: .main) as AdaEngine.FontResource
        self.font = Font(fontResource: fontRes, pointSize: 32)
        
        self.showLogo()
    }
    
    private func showLogo() {
        self.addEntity(
            Entity(name: "Logo") {
                UIComponent(
                    view: LaunchSceneView(font: font),
                    behaviour: .overlay
                )
            }
        )
    }
}

struct LaunchSceneView: View {

    let font: Font

    @Environment(\.scene) private var scene
    @State private var opacity: Float = 0

    var body: some View {
        VStack {
            Text("Powered by AdaEngine")
                .font(font)
                .offset(x: 50, y: 0)
        }
        .foregroundColor(.white.opacity(opacity))
        .frame(width: 400, height: 400)
        .onAppear {
            Task {
                for i in 0...100 {
                    try await Task.sleep(nanoseconds: 1_000_000 * 50)
                    self.opacity = Float(i) / 100
                }

                for i in 0...100 {
                    try await Task.sleep(nanoseconds: 1_000_000 * 50)
                    self.opacity = 1 - Float(i) / 100
                }

                self.presentMainScene()
            }
        }
    }

    @MainActor
    private func presentMainScene() {
        self.scene?.value?.clearAllEntities()
        self.scene?.value?.sceneManager?.presentScene(MainScene())
    }
}
