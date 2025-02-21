//
//  GameScene.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 18.02.2025.
//

import AdaEngine

class GameScene: Scene {
    
    private var characters: TextureAtlas!
    private var background: Texture2D!
    
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
                print(error)
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
        ]
    }
}

private extension GameScene {
    
    @MainActor
    func preloadAssets() async throws {
        let image = try await ResourceManager.load("duck_hunt_characters.png", from: .main) as AdaEngine.Image
        self.characters = TextureAtlas(from: image, size: SizeInt(width: 16, height: 16))
    }
    
    @MainActor
    func setupScene() async throws {
        try await preloadAssets()
        self.createPlayer()
        
        self.addEntity(
            Entity(name: "Grass") {
                SpriteComponent(tintColor: .green)
                Transform(rotation: .identity, scale: [20, 1, 1], position: [0, -2, 0])
                Collision2DComponent(
                    shapes: [
                        .generateBox()
                    ],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
            }
        )
        
        self.addEntity(
            Entity(name: "Terrain") {
                SpriteComponent(tintColor: .brown)
                Transform(rotation: .identity, scale: [20, 6, 1], position: [0, -5.5, 0])
                Collision2DComponent(
                    shapes: [
                        .generateBox()
                    ],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
            }
        )
        
        self.addEntity(
            Entity(name: "Grass Layer 1") {
                SpriteComponent(tintColor: Color.gray)
                Transform(rotation: .identity, scale: [20, 1, 1], position: [0, -3.5, 0])
                Collision2DComponent(
                    shapes: [
                        .generateBox()
                    ],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
            }
        )
    }
    
    private func createPlayer() {
        func createAnimationTexture(
            textures: [Texture2D]
        ) -> Texture2D {
            let animatedTexture = AnimatedTexture()
            animatedTexture.framesPerSecond = 5
            animatedTexture.framesCount = 2
            
            textures.enumerated().forEach { index, texture in
                animatedTexture[index] = texture
            }

            return animatedTexture
        }
        
        func createAnimations() -> [String: Texture2D] {
            var animations: [String: Texture2D] = [:]
            
            let idle = createAnimationTexture(
                textures: [
                    characters[0, 0],
                    characters[0, 1],
                ]
            )
            
            let dash = createAnimationTexture(
                textures: [
                    characters[2, 2],
                    characters[2, 3],
                ]
            )
            
            let flightUp = createAnimationTexture(
                textures: [
                    characters[2, 0],
                    characters[2, 1],
                    characters[2, 2],
                ]
            )
            
            let flightDiagonal = createAnimationTexture(
                textures: [
                    characters[1, 0],
                    characters[1, 1],
                    characters[1, 2],
                ]
            )
            
            animations[PlayerAnimationState.idle.rawValue] = idle
            animations[PlayerAnimationState.dash.rawValue] = dash
            animations[PlayerAnimationState.flightUp.rawValue] = flightUp
            animations[PlayerAnimationState.flightDiagonal.rawValue] = flightDiagonal
            
            return animations
        }
        
        self.addEntity(
            Entity(name: "Player") {
                SpriteComponent()
                Transform(rotation: .identity, scale: .one, position: [0, 0, 0])
                PlayerComponent()
                CameraFollowing()
                PlayerImpulseArrow()
                
                SpriteAnimation(
                    animations: createAnimations(),
                    currentAnimation: PlayerAnimationState.idle.rawValue
                )
                
                PhysicsBody2DComponent(
                    shapes: [.generateBox()],
                    mass: 1,
                    mode: .dynamic
                )
                .setFixedRotation(true)
                .setFilter(
                    CollisionFilter(
                        categoryBitMask: .player,
                        collisionBitMask : [.obstacles, .enemies]
                    )
                )
            }
        )
    }
}

@Component
struct PlayerComponent {
    var dashCount: Int = 4
    var dashCooldown: TimeInterval = 0
    
    var direction: Vector2 = .zero
}

extension CollisionGroup {
    static let player = CollisionGroup(rawValue: 1 << 1)
    static let enemies = CollisionGroup(rawValue: 1 << 2)
    static let obstacles = CollisionGroup(rawValue: 1 << 3)
}

enum PlayerAnimationState: String {
    case idle
    case flightUp
    case flightDiagonal
    case dash
}
