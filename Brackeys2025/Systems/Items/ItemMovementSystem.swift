//
//  ItemMovementSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

struct ItemMovementSystem: System {
    
    static let items = EntityQuery(where: .has(BonusItem.self) && .has(Transform.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        context.scene.performQuery(Self.items).forEach { entity in
            var bonusItem = entity.components[BonusItem.self]!
            
            bonusItem.currentTime += context.deltaTime
            if bonusItem.currentTime > bonusItem.lifetime {
                entity.removeFromScene()
                return
            }
        }
    }
}
