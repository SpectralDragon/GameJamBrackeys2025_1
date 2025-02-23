//
//  TargetMovementSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct TargetComponent {
    
    enum State {
        case chase
        case catchTarget
        case fire
    }
    
    var state: State = .chase
    var spawnTargetPosition: Vector3
    
    var fireDelay: TimeInterval = 2
    var currentTime: TimeInterval = 0
}

struct TargetMovementSystem: System {
    
    static var player = EntityQuery(where: .has(Transform.self) && .has(PlayerComponent.self))
    static var difficulty = EntityQuery(where: .has(DifficultyComponent.self))
    static var targets = EntityQuery(
        where: .has(Transform.self) && .has(TargetComponent.self)
    )
    
    static var dependencies: [SystemDependency] = [
        .after(PlayerMovementSystem.self)
    ]
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard let playerEntity = context.scene.performQuery(Self.player).first else {
            return
        }
        
        guard
            let director = context.scene.performQuery(Self.difficulty).first,
            let difficulty = director.components[DifficultyComponent.self]
        else {
            return
        }
        
        let playerTransform = playerEntity.components[Transform.self]!
        context.scene.performQuery(Self.targets).forEach { entity in
            var (transform, target) = entity.components[Transform.self, TargetComponent.self]
            
            switch target.state {
            case .chase:
                let newPosition = lerp(
                    transform.position,
                    playerTransform.position,
                    difficulty.currentLevel.targetSpeed * context.deltaTime
                )
                
                transform.position = newPosition
            case .catchTarget:
                transform.position = playerTransform.position
                target.currentTime += context.deltaTime
                
                if target.currentTime > target.fireDelay {
                    target.state = .fire
                }
            default:
                break
            }
            
            entity.components += transform
            entity.components += target
        }
    }
}
