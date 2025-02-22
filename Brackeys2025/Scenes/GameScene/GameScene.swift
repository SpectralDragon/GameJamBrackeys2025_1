//
//  GameScene.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 18.02.2025.
//

import AdaEngine

class GameScene: Scene {
    
    private(set) var characters: TextureAtlas!
    private(set) var miscAtlas: TextureAtlas!
    private(set) var font: Font!
    
    private var disposeBag: Set<AnyCancellable> = []
    
    override func sceneDidLoad() {
//        self.physicsWorld2D?.gravity = [0, -0.3]
        self.physicsWorld2D?.gravity = [0, 0]
    }
    
    override func sceneDidMove(to view: SceneView) {
        let camera = OrthographicCamera()
        camera.camera.orthographicScale = 7
        camera.camera.backgroundColor = Color(41/255, 173/255, 255/255, 1)
        self.addEntity(camera)
        
        self.debugOptions = [.showPhysicsShapes]
        self.debugPhysicsColor = .red
        
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
        
        self.subscribe(to: CollisionEvents.Began.self) { event in
            print("event", event)
        }
        .store(in: &disposeBag)
    }
}

private extension GameScene {
    private var systems: [System.Type] {
        [
            CameraFollowSystem.self,
            PlayerMovementSystem.self,
            PlayerMovementDashIndicator.self,
            ParallaxSystem.self,
            AnimationSystem.self,
            PlayerAnimationSystem.self,
            DashIndicatorSystem.self,
            TargetSpawnSystem.self,
            TargetMovementSystem.self
        ]
    }
}

private extension GameScene {
    
    @MainActor
    func preloadAssets() async throws {
        let charImage = try await ResourceManager.load("duck_hunt_characters.png", from: .main) as AdaEngine.Image
        self.characters = TextureAtlas(from: charImage, size: SizeInt(width: 16, height: 16))
        
        let miscImage = try await ResourceManager.load("misc.png", from: .main) as AdaEngine.Image
        self.miscAtlas = TextureAtlas(from: miscImage, size: SizeInt(width: 16, height: 16))
        
        let fontRes = try await ResourceManager.load("PixelSmall.ttf", from: .main) as AdaEngine.FontResource
        self.font = Font(fontResource: fontRes, pointSize: 32)
    }
    
    @MainActor
    func setupScene() async throws {
        try await preloadAssets()
        self.createPlayer()
        self.setupLevel()
        self.setupEnemies()
    }
}

extension CollisionGroup {
    static let player = CollisionGroup(rawValue: 1 << 1)
    static let enemies = CollisionGroup(rawValue: 1 << 2)
    static let obstacles = CollisionGroup(rawValue: 1 << 3)
}
