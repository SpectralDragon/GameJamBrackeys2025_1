//
//  GameScene.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 18.02.2025.
//

import AdaEngine

class GameScene: Scene {
    
    private var characters: TextureAtlas = {
        let image = try! ResourceManager.loadSync("duck_hunt_characters.png", from: .main) as AdaEngine.Image
        return TextureAtlas(from: image, size: SizeInt(width: 16, height: 16))
    }()
    
    private var disposeBag: Set<AnyCancellable> = []
    
    override func sceneDidLoad() {
        self.physicsWorld2D?.gravity = [0, 0]
    }
    
    override func sceneDidMove(to view: SceneView) {
        let camera = OrthographicCamera()
        camera.camera.orthographicScale = 5
        camera.camera.backgroundColor = Color(41/255, 173/255, 255/255, 1)
        self.addEntity(camera)
        
        self.debugOptions = [.showPhysicsShapes]
        self.debugPhysicsColor = .red

        self.addEntity(
            Entity(name: "Player") {
                SpriteComponent(texture: characters[0, 0])
                Transform(rotation: .identity, scale: .one, position: [0, 0, 1])
                PlayerComponent()
                CameraFollowing()
                PlayerImpulseArrow()
                
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
        
        self.addEntity(
            Entity(name: "Terrain") {
                SpriteComponent(tintColor: .brown)
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
        
        self.addSystem(CameraFollowSystem.self)
        self.addSystem(PlayerMovementSystem.self)
        self.addSystem(PlayerMovementDashIndicator.self)
        
        self.subscribe(to: CollisionEvents.Began.self) { event in
            print("event", event)
        }
        .store(in: &disposeBag)
    }
}

private extension GameScene {
    
}

@Component
struct PlayerComponent {
    
}

struct AnimationSystem: System {
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        
    }
    
}

extension CollisionGroup {
    static let player = CollisionGroup(rawValue: 1 << 1)
    static let enemies = CollisionGroup(rawValue: 1 << 2)
    static let obstacles = CollisionGroup(rawValue: 1 << 3)
}
