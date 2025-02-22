//
//  GameScene+Enemies.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

extension GameScene {
    func setupEnemies() {
        let targetSpawnerEntity = Entity(name: "TargetSpawner") {
            TargetSpawnSystemSettings(
                targetTexture: miscAtlas[1, 0],
                maxTargets: 1,
                isEnabled: true
            )
        }
        
        self.addEntity(targetSpawnerEntity)
    }
}
