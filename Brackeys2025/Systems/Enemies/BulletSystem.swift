//
//  BulletSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct Bullet {
    var lifetime: TimeInterval = 4
    var currentLifetime: TimeInterval = 0
    var direction: Vector3
}

struct BulletSystem: System {

    static let bullet = EntityQuery(where: .has(Bullet.self) && .has(PhysicsBody2DComponent.self))
    static var difficulty = EntityQuery(where: .has(DifficultyComponent.self))

    init(scene: Scene) { }

    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard
            let director = context.scene.performQuery(Self.difficulty).first,
            let difficulty = director.components[DifficultyComponent.self]
        else {
            return
        }
        
        context.scene.performQuery(Self.bullet).forEach { entity in
            var (bullet, physicsBody, transform) = entity.components[
                Bullet.self, PhysicsBody2DComponent.self, Transform.self
            ]

            if physicsBody.linearVelocity == .zero {
                let direction = (bullet.direction - transform.position) * difficulty.currentLevel.bulletSpeed
                physicsBody.linearVelocity = direction.xy
            }
            
            if physicsBody.linearVelocity == .zero {
                entity.removeFromScene()
            }

            bullet.currentLifetime += context.deltaTime

            if bullet.lifetime > bullet.currentLifetime {
                entity.components += bullet
            } else {
                entity.removeFromScene()
            }
        }
    }
}
