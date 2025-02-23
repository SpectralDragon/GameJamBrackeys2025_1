//
//  TargetShootSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

struct TargetShootSystem: System {
    
    static var player = EntityQuery(where: .has(PlayerComponent.self) && .has(Transform.self))
    static var targets = EntityQuery(where: .has(TargetComponent.self))
    static var statistics = EntityQuery(where: .has(Statistics.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard
            let statisticsEntity = context.scene.performQuery(Self.statistics).first,
            var statistics = statisticsEntity.components[Statistics.self]
        else {
            return
        }
        defer { statisticsEntity.components += statistics }
        
        context.scene.performQuery(Self.targets).forEach { entity in
            let (transform, target) = entity.components[Transform.self, TargetComponent.self]
            
            guard target.state == .fire else {
                return
            }
            
            spawnBullet(
                in: context.scene,
                direction: transform.position,
                target: target
            )
            statistics.bulletFired += 1
            entity.removeFromScene()
        }
    }
}

private extension TargetShootSystem {
    @MainActor
    func spawnBullet(
        in scene: Scene,
        direction: Vector3,
        target: TargetComponent
    ) {
        scene.addEntity(
            Entity(name: "Bullet!") {
                Transform(
                    scale: [0.3, 0.3, 0.3],
                    position: target.spawnTargetPosition
                )
                SpriteComponent(tintColor: .orange)
                PhysicsBody2DComponent(shapes: [
                    .generateBox()
                ])
                .setFilter(
                    CollisionFilter(
                        categoryBitMask: .enemies,
                        collisionBitMask: .player
                    )
                )
                .setGravityScale(0.0)
                .setMode(.kinematic)
                
                Collision2DComponent(
                    shapes: [.generateBox()],
                    mode: .trigger
                )
                .setFilter(
                    CollisionFilter(
                        categoryBitMask: .enemies,
                        collisionBitMask: .player
                    )
                )
                
                Bullet(
                    direction: direction
                )
            }
        )
    }
}
