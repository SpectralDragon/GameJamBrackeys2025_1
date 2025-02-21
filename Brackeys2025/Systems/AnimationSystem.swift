//
//  AnimationSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct SpriteAnimation {
    let animations: [String: Texture2D]
    var currentAnimation: String
    
    init(animations: [String : Texture2D], currentAnimation: String) {
        precondition(animations.keys.contains(currentAnimation), "Current animation not found in animations")
        precondition(!animations.isEmpty, "Animations is empty")
        
        self.animations = animations
        self.currentAnimation = currentAnimation
    }
}

struct AnimationSystem: System {
    
    static let animations = EntityQuery(where: .has(SpriteAnimation.self) && .has(SpriteComponent.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        context.scene.performQuery(Self.animations).forEach { entity in
            let spriteAnimation = entity.components[SpriteAnimation.self]!
            var sprite = entity.components[SpriteComponent.self]!
            
            if let texture = spriteAnimation.animations[spriteAnimation.currentAnimation] {
                sprite.texture = texture
                entity.components += sprite
            }
        }
    }
}
