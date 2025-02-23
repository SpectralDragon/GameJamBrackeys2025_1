//
//  LaunchScene.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

class LaunchScene: AdaEngine.Scene {
    
    private(set) var logoItem: Texture2D!
    private(set) var font: Font!
    
    private var gameloop: (any Cancellable)?
    
    var currentTime: TimeInterval = 0
    
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
        let image = try await ResourceManager.load("ada_engine.png", from: .main) as AdaEngine.Image
        self.logoItem = Texture2D(image: image)
        
        let fontRes = try await ResourceManager.load("PixelSmall.ttf", from: .main) as AdaEngine.FontResource
        self.font = Font(fontResource: fontRes, pointSize: 32)
        
        self.showLogo()
        
        self.gameloop = self.subscribe(to: EngineEvents.GameLoopBegan.self) { [weak self] event in
            self?.update(event.deltaTime)
        }
    }
    
    private func update(_ timeInterval: TimeInterval) {
        self.currentTime += timeInterval
        
        if currentTime > 4 {
            self.presentMainScene()
        }
    }
    
    private func showLogo() {
        self.addEntity(
            Entity(name: "Logo") {
                Transform(scale: Vector3(5))
                
                SpriteComponent(texture: logoItem)
            }
        )
    }
    
    private func presentMainScene() {
        self.clearAllEntities()
        self.sceneManager?.presentScene(MainScene())
    }
}
