//
//  TargetSpawnSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

struct TargetSpawnSystem: System {
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        
    }
}

private extension TargetSpawnSystem {
    @MainActor
    func spawnTarget(in scene: Scene) {
        let targetEntity = Entity(name: "Target") {
            
        }
        
        scene.addEntity(targetEntity)
    }
}
