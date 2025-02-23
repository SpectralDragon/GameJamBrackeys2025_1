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
        
        self.addEntity(
            Entity(name: "Grass") {
                SpriteComponent(tintColor: .green)
                Transform(rotation: .identity, scale: [30, 1, 1], position: [0, 0.5, 0])
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
                Transform(rotation: .identity, scale: [30, 6, 1], position: [0, -2.5, 0])
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
