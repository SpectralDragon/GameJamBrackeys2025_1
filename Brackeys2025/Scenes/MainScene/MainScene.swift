//
//  ContentView.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 17.02.2025.
//

import AdaEngine

class MainScene: Scene {
    
    private(set) var characters: TextureAtlas!
    private(set) var miscAtlas: TextureAtlas!
    private(set) var font: Font!
    
    override func sceneDidMove(to view: SceneView) {
        let camera = OrthographicCamera()
        camera.camera.orthographicScale = 4
        camera.camera.backgroundColor = Game.cameraBackgroundColor
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
        
        self.systems.forEach {
            self.addSystem($0)
        }
    }
    
    deinit {
        #if DEBUG
        print("Deinited MainScene")
        #endif
    }
}

private extension MainScene {
    private var systems: [System.Type] {
        [
            ParallaxSystem.self,
            AnimationSystem.self
        ]
    }
}

private extension MainScene {
    @MainActor
    private func setupScene() async throws {
        try await preloadAssets()
        self.setupEnvironment()
        self.setupUI()
    }
    
    @MainActor
    func preloadAssets() async throws {
        let charImage = try await ResourceManager.load("duck_hunt_characters.png", from: .main) as AdaEngine.Image
        self.characters = TextureAtlas(from: charImage, size: SizeInt(width: 16, height: 16))
        
        let miscImage = try await ResourceManager.load("misc.png", from: .main) as AdaEngine.Image
        self.miscAtlas = TextureAtlas(from: miscImage, size: SizeInt(width: 16, height: 16))
        
        let fontRes = try await ResourceManager.load("PixelSmall.ttf", from: .main) as AdaEngine.FontResource
        self.font = Font(fontResource: fontRes, pointSize: 32)
    }
    
}
