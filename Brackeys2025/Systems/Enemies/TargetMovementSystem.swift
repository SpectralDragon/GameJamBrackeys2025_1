//
//  TargetMovementSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct TargetComponent {
    var speed: Float = 0.3
}

struct TargetMovementSystem: System {
    
    static var player = EntityQuery(where: .has(Transform.self) && .has(PlayerComponent.self))
    static var targets = EntityQuery(
        where: .has(Transform.self) && .has(TargetComponent.self)
    )
    
    static var dependencies: [SystemDependency] = [
        .after(PlayerMovementSystem.self)
    ]
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        guard let playerEntity = context.scene.performQuery(Self.player).first else {
            return
        }
        
        let playerTransform = playerEntity.components[Transform.self]!
        context.scene.performQuery(Self.targets).forEach { entity in
            var (transform, target) = entity.components[Transform.self, TargetComponent.self]
            
            let newPosition = lerp(
                transform.position,
                playerTransform.position,
                target.speed * context.deltaTime
            )
            
            transform.position = newPosition
            entity.components += transform
        }
    }
}
