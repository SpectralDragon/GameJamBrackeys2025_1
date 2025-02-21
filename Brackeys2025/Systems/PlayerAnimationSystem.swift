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
        
        var (playerComponent, spriteAnimation, spriteComponent) = player.components[
            PlayerComponent.self, SpriteAnimation.self, SpriteComponent.self
        ]
        
        updateAnimation(
            &spriteAnimation,
            &spriteComponent,
            playerComponent
        )
        
        player.components += spriteAnimation
        player.components += spriteComponent
        
        var transform = player.components[Transform.self]!
        
        player.components[Transform.self] = transform
    }
}

private extension PlayerAnimationSystem {
    private func updateAnimation(
        _ spriteAnimation: inout SpriteAnimation,
        _ spriteComponent: inout SpriteComponent,
        _ playerComponent: PlayerComponent
    ) {
        var flipX = false
        
        if playerComponent.direction.x < 0 {
            flipX = true
        }
        
        var animation: PlayerAnimationState = .idle
        
        if playerComponent.direction.y > 0 {
            if abs(playerComponent.direction.x) < 0.5 {
                animation = .flightUp
            } else {
                animation = .flightDiagonal
            }
        }
        
        print(playerComponent.direction, flipX, animation.rawValue)
        
        spriteAnimation.currentAnimation = animation.rawValue
    }
}
