//
//  MainScene+Environment.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

extension MainScene {
    func setupEnvironment() {
        self.createPlayer()
        self.generateGrass()
        
        var position: Float = -10
        for _ in 0..<30 {
            self.addEntity(
                Entity(name: "Terrain") {
                    SpriteComponent(
                        texture: miscAtlas[Int.random(in: 3...4), 4]
                    )
                    Transform(
                        rotation: .identity,
                        scale: [1, 1, 1],
                        position: [position, 0, 1]
                    )
                }
            )
            
            position += 1
        }
        
        
        self.addEntity(
            Entity(name: "Terrain") {
                SpriteComponent(tintColor: Game.groundColor)
                Transform(rotation: .identity, scale: [30, 3, 1], position: [0, -2, 0])
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
    
    private func generateGrass() {
        var position: Float = -10
        for _ in 0..<30 {
            self.addEntity(
                Entity(name: "Grass") {
                    SpriteComponent(
                        texture: miscAtlas[Int.random(in: 0...1), 4]
                    )
                    Transform(
                        rotation: .identity,
                        scale: [1, 1, 1],
                        position: [position, 1, 1]
                    )
                }
            )
            
            position += 1
        }
    }
    
    func createPlayer() {
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
            
            animations[PlayerAnimationState.idleGroundLeft.rawValue] = idleGroundLeft
            animations[PlayerAnimationState.idleGroundRight.rawValue] = idleGroundRight
            animations[PlayerAnimationState.walkingLeft.rawValue] = walkingLeft
            animations[PlayerAnimationState.walkingRight.rawValue] = walkingRight
            
            return animations
        }
        
        let player = Entity(name: "Player") {
            SpriteComponent()
            Transform(position: [0, -0.5, 1])
            
            SpriteAnimation(
                animations: createAnimations(),
                currentAnimation: PlayerAnimationState.idleGroundRight.rawValue
            )
        }
        self.addEntity(player)
    }
}
