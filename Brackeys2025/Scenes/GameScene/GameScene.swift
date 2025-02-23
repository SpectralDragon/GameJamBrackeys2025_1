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
    
    weak var gameMaster: Entity?
    weak var shootEntity: Entity?
    
    private var backgroundColor = Color(41/255, 173/255, 255/255, 1)
    
    private var disposeBag: Set<AnyCancellable> = []
    
    override func sceneDidLoad() {
        self.physicsWorld2D?.gravity = [0, -0.3]
    }
    
    override func sceneDidMove(to view: SceneView) {
        let camera = OrthographicCamera()
        camera.camera.orthographicScale = 7
        camera.camera.backgroundColor = self.backgroundColor
        self.addEntity(camera)
        
        Game.isPaused = false
        
        #if DEBUG
//        self.debugOptions = [.showPhysicsShapes]
//        self.debugPhysicsColor = .red
        #endif
        
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
        
        self.subscribe(to: GameEvents.OnStateChange.self) { event in
            Game.state = event.state
        }
        .store(in: &disposeBag)
        
        self.subscribe(to: GameEvents.OnShoot.self) { _ in
            self.shootEffect()
        }
        .store(in: &disposeBag)
        
        self.subscribe(to: CollisionEvents.Began.self) { event in
            self.onCollisionBegan(event.entityA, event.entityB)
        }
        .store(in: &disposeBag)
    }
    
    func gameOver() {
        guard let gameMaster else {
            return
        }
        
        let (difficulty, statistics) = gameMaster.components[DifficultyComponent.self, Statistics.self]
        let gameOver = GameOver(
            totalTime: difficulty.currentTimer,
            statistics: statistics
        )
        
        self.eventManager.send(
            GameEvents.OnStateChange(
                state: .gameOver(gameOver)
            )
        )
        
        Game.isPaused = true
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
            TargetMovementSystem.self,
            TargetShootSystem.self,
            BulletSystem.self,
            DifficultySystem.self,
            ItemSpawnerSystem.self,
            ItemMovementSystem.self,
            ShootEffectSystem.self
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
        self.setupUI()
        self.setupGameMaster()
        
        // TODO: FIXME
        self.eventManager.send(GameEvents.OnStateChange(state: .playing))
    }
}

private extension GameScene {
    func shootEffect() {
        if let shootEntity, shootEntity.isActive {
            return
        }
        
        let entity = Entity(name: "Shoot Effect") {
            ShootEffect(
                cameraBackground: self.backgroundColor
            )
        }
        self.shootEntity = entity
        self.addEntity(entity)
    }
}

extension CollisionGroup {
    static let player = CollisionGroup(rawValue: 1 << 1)
    static let enemies = CollisionGroup(rawValue: 1 << 2)
    static let obstacles = CollisionGroup(rawValue: 1 << 3)
    static let targets = CollisionGroup(rawValue: 1 << 4)
    static let bonusItems = CollisionGroup(rawValue: 1 << 5)
}

enum GameState {
    case idle
    case playing
    case gameOver(GameOver)
}

enum GameEvents {
    struct OnStateChange: Event {
        let state: GameState
    }
    
    struct OnShoot: Event {}
}

struct GameOver {
    let totalTime: TimeInterval
    let statistics: Statistics
}

@Component
struct Statistics {
    var bulletFired: Int = 0
    var itemsCollected = 0
}

struct Game {
    static var isPaused = false
    static var state: GameState = .idle
}
