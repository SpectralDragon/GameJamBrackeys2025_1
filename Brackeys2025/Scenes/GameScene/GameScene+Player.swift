//
//  GameScene+Player.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct PlayerComponent {
    var direction: Vector2 = .zero
    var jumpSound: AudioResource
}

enum PlayerAnimationState: String {
    case idleGroundRight, idleGroundLeft
    case walkingRight, walkingLeft
    case flightLeftDiagonal, flightRightDiagonal
    
    case flightLeft, flightRight
    case flightUp, flightDown
    
    case dash
}

extension GameScene {
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
            PlayerComponent(jumpSound: self.jumpSound)
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
                    collisionBitMask : .all
                )
            )
        }
        
        player.prepareAudio(self.jumpSound)
            .setVolume(0.3)
        
        player.addChild(indicator)
        self.addEntity(player)
        self.addEntity(indicator)
    }
}
