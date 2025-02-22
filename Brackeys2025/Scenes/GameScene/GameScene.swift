//
//  GameScene.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 18.02.2025.
//

import AdaEngine

class GameScene: Scene {
    
    private var characters: TextureAtlas!
    private var miscAtlas: TextureAtlas!
    private var font: Font!
    private var background: Texture2D!
    
    private var disposeBag: Set<AnyCancellable> = []
    
    override func sceneDidLoad() {
        self.physicsWorld2D?.gravity = [0, -0.3]
//        self.physicsWorld2D?.gravity = [0, 0]
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
            DashIndicatorSystem.self
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
            
            let idleGroundRight = characters[0, 0]
            let idleGroundLeft  = characters[1, 0]
            
            let walkingRight = createAnimationTexture(
                textures: [
                    characters[0, 1],
                    characters[0, 2],
                ]
            )
            
            let walkingLeft = createAnimationTexture(
                textures: [
                    characters[1, 1],
                    characters[1, 2],
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
                    characters[4, 0],
                    characters[4, 1],
                    characters[4, 2],
                ]
            )
            
            let flightDown = characters[4, 3]
            
            let flightLeftDiagonal = createAnimationTexture(
                textures: [
                    characters[2, 0],
                    characters[2, 1],
                    characters[2, 2],
                ]
            )
            
            let flightRightDiagonal = createAnimationTexture(
                textures: [
                    characters[3, 0],
                    characters[3, 1],
                    characters[3, 2],
                ]
            )
            
            let flightLeft = createAnimationTexture(
                textures: [
                    characters[5, 0],
                    characters[5, 1],
                    characters[5, 2],
                ]
            )
            
            let flightRight = createAnimationTexture(
                textures: [
                    characters[6, 0],
                    characters[6, 1],
                    characters[6, 2],
                ]
            )
            
            animations[PlayerAnimationState.idleGroundLeft.rawValue] = idleGroundLeft
            animations[PlayerAnimationState.idleGroundRight.rawValue] = idleGroundRight
            animations[PlayerAnimationState.walkingLeft.rawValue] = walkingLeft
            animations[PlayerAnimationState.walkingRight.rawValue] = walkingRight
            
            animations[PlayerAnimationState.dash.rawValue] = dash
            animations[PlayerAnimationState.flightUp.rawValue] = flightUp
            animations[PlayerAnimationState.flightDown.rawValue] = flightDown
            
            animations[PlayerAnimationState.flightRightDiagonal.rawValue] = flightRightDiagonal
            animations[PlayerAnimationState.flightLeftDiagonal.rawValue] = flightLeftDiagonal
            
            animations[PlayerAnimationState.flightRight.rawValue] = flightRight
            animations[PlayerAnimationState.flightLeft.rawValue] = flightLeft
            
            return animations
        }
        
        let indicator = Entity(name: "DashIndicator") {
            DashIndicator(
                maxDashCount: 4,
                dashCooldown: 1.5,
                dashTexture: miscAtlas[0, 0]
            )
            NoFrustumCulling()
            Transform(scale: [1, 1, 1], position: [0, 0.7, 0])
        }
        
        let player = Entity(name: "Player") {
            SpriteComponent()
            Transform()
            PlayerComponent()
            CameraFollowing()
            PlayerImpulseArrow()
            
            SpriteAnimation(
                animations: createAnimations(),
                currentAnimation: PlayerAnimationState.idleGroundRight.rawValue
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
        
        player.addChild(indicator)
        self.addEntity(player)
        self.addEntity(indicator)
    }
}

private extension GameScene {
    func setupLevel() {
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
}

@Component
struct PlayerComponent {
    var direction: Vector2 = .zero
}

extension CollisionGroup {
    static let player = CollisionGroup(rawValue: 1 << 1)
    static let enemies = CollisionGroup(rawValue: 1 << 2)
    static let obstacles = CollisionGroup(rawValue: 1 << 3)
}

enum PlayerAnimationState: String {
    case idleGroundRight, idleGroundLeft
    case walkingRight, walkingLeft
    case flightLeftDiagonal, flightRightDiagonal
    
    case flightLeft, flightRight
    case flightUp, flightDown
    
    case dash
}
