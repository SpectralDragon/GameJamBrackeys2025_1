//
//  ItemSpawnerSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

enum ItemType {
    case cooldownReduced
    case addDash
    case slowMode
    case infiniteDash
}

@Component
struct BonusItem {
    let type: ItemType
    let permanent: Bool
    let texture: Texture2D
    
    let lifetime: TimeInterval = 20
    var currentTime: TimeInterval = 0
}

@Component
struct ItemSpawnSettingsComponent {
    var lastSpawnTime: TimeInterval = 0
    var currentTime: TimeInterval = 0
    
    let items: [BonusItem]
}

struct ItemSpawnerSystem: System {
    
    static let spawnSettings = EntityQuery(where: .has(ItemSpawnSettingsComponent.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard
            let entity = context.scene.performQuery(Self.spawnSettings).first,
            var spawnSettings = entity.components[ItemSpawnSettingsComponent.self]
        else {
            return
        }
        
        defer {
            entity.components += spawnSettings
        }
        
        spawnSettings.currentTime += context.deltaTime
        
        if spawnSettings.currentTime - spawnSettings.lastSpawnTime > 4  {
            spawnItem(context, spawnSettings.items.randomElement()!)
            spawnSettings.lastSpawnTime = spawnSettings.currentTime
        }
    }
}

private extension ItemSpawnerSystem {
    @MainActor
    func spawnItem(
        _ context: SceneUpdateContext,
        _ item: BonusItem
    ) {
        let entity = Entity(name: "Bonus Item") {
            Transform(
                position: [Float.random(in: -10..<10), 13, 0]
            )
            
            SpriteComponent(texture: item.texture)
            
            PhysicsBody2DComponent(shapes: [
                .generateBox()
            ], mode: .kinematic)
            .setLinearVelocity([0, -2])
            
            Collision2DComponent(
                shapes: [.generateBox()],
                mode: .trigger,
                filter: CollisionFilter(
                    categoryBitMask: .bonusItems,
                    collisionBitMask: .player
                )
            )
            
            item
        }
        
        context.scene.addEntity(entity)
    }
}
