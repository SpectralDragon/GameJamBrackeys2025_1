//
//  PlayerAnimationSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

struct PlayerAnimationSystem: System {
    
    static let player = EntityQuery(where: .has(PlayerComponent.self) && .has(SpriteAnimation.self) && .has(SpriteComponent.self))
    
    static var dependencies: [SystemDependency] = [
        .after(PlayerMovementSystem.self),
        .before(AnimationSystem.self)
    ]
    
    init(scene: Scene) { }
    
    func update(context: UpdateContext) {
        guard let player = context.scene.performQuery(Self.player).first else {
            return
        }
        
        var (playerComponent, spriteAnimation) = player.components[
            PlayerComponent.self, SpriteAnimation.self
        ]
        
        updateAnimation(
            &spriteAnimation,
            playerComponent
        )
        
        player.components += spriteAnimation
    }
}

private extension PlayerAnimationSystem {
    private func updateAnimation(
        _ spriteAnimation: inout SpriteAnimation,
        _ playerComponent: PlayerComponent
    ) {
        var isLeft = false
        
        let direction = playerComponent.direction
        
        if direction.x < 0 {
            isLeft = true
        }
        
        var animation: PlayerAnimationState = .idleGroundRight
        
        if direction.y > 0.3 {
            if abs(playerComponent.direction.x) < 0.5 {
                animation = .flightUp
            } else {
                animation = isLeft ? .flightLeftDiagonal : .flightRightDiagonal
            }
        } else if direction.y < 0 {
            animation = .flightDown
        } else if direction.y == 0 {
            animation = isLeft ? .flightLeft : .flightRight
        }
        
        spriteAnimation.currentAnimation = animation.rawValue
    }
}
