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
    var nextItemCooldown: TimeInterval = 4
    var nextItem: BonusItem? = nil
    
    let items: [BonusItem]
}

struct ItemSpawnerSystem: System {
    
    static let spawnSettings = EntityQuery(where: .has(ItemSpawnSettingsComponent.self))
    static let difficulty = EntityQuery(where: .has(DifficultyComponent.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard
            let difficultyEntity = context.scene.performQuery(Self.difficulty).first,
            var difficulty = difficultyEntity.components[DifficultyComponent.self]
        else {
            return
        }
        
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
        
        // Pick item
        if spawnSettings.nextItem == nil {
            let itemType = difficulty.currentLevel.availableItems.randomElement()
            spawnSettings.nextItem = spawnSettings.items.first(where: { $0.type == itemType })
            spawnSettings.nextItemCooldown = .random(in: 5..<13)
        }
        
        guard let nextItem = spawnSettings.nextItem else {
            return
        }
        
        if spawnSettings.currentTime - spawnSettings.lastSpawnTime > spawnSettings.nextItemCooldown  {
            spawnItem(context, nextItem)
            spawnSettings.lastSpawnTime = spawnSettings.currentTime
            spawnSettings.nextItem = nil
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
                position: [Float.random(in: -10..<10), 30, 0]
            )
            
            SpriteComponent(texture: item.texture)
            
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
