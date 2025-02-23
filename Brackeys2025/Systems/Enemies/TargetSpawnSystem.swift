//
//  TargetSpawnSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct TargetSpawnSystemSettings {
    let targetTexture: Texture2D
    let shootSound: AudioResource
    var maxTargets: Int
    
    var isEnabled: Bool
}

struct TargetSpawnSystem: System {
    
    static let spawnSettings = EntityQuery(where: .has(TargetSpawnSystemSettings.self))
    static var targets = EntityQuery(where: .has(TargetComponent.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard let spawnerEntity = context.scene.performQuery(Self.spawnSettings).first else {
            return
        }
        
        guard
            let spawnerSettings = spawnerEntity.components[TargetSpawnSystemSettings.self],
                spawnerSettings.isEnabled
        else {
            return
        }
        
        let targetsCount = context.scene.performQuery(Self.targets).count
        if targetsCount < spawnerSettings.maxTargets {
            spawnTarget(
                in: context.scene,
                settings: spawnerSettings,
                parent: spawnerEntity
            )
        }
    }
}

private extension TargetSpawnSystem {
    @MainActor
    func spawnTarget(
        in scene: Scene,
        settings: TargetSpawnSystemSettings,
        parent: Entity
    ) {
        let isLeft = Bool.random()
        let isBottom = Bool.random()
        
        let position: Vector3 = [
            Float.random(in: isLeft ? -15 ..< 10 : 10 ..< 15),
            Float.random(in: isBottom ? -15 ..< -5 : 15 ..< 20),
            0
        ]
        
        let targetEntity = Entity(name: "Target") {
            SpriteComponent(texture: settings.targetTexture)
            Transform(position: position)
            
            Collision2DComponent(
                shapes: [.generateBox()],
                mode: .trigger,
                filter: CollisionFilter(
                    categoryBitMask: .targets,
                    collisionBitMask: .player
                )
            )
            
            TargetComponent(spawnTargetPosition: position)
        }
        
        scene.addEntity(targetEntity)
    }
}
