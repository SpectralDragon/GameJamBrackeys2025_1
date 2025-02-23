//
//  DifficultySystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

struct DifficultyLevel {
    var time: TimeInterval
    var maxTargets: Int
    var targetSpeed: Float
    var bulletSpeed: Float
    var availableItems: [ItemType]
}

@Component
struct DifficultyComponent {
    let levels: [DifficultyLevel]
    var currentLevel: DifficultyLevel
    var currentTimer: TimeInterval = 0
    var lastLevelChangeTime: TimeInterval = 0
    var levelIndex: Int = 0
    
    init(levels: [DifficultyLevel]) {
        precondition(!levels.isEmpty)
        self.levels = levels
        self.currentLevel = levels.first!
    }
}

struct DifficultySystem: System {
    
    static let difficulty = EntityQuery(where: .has(DifficultyComponent.self))
    
    static let targetSpawner = EntityQuery(where: .has(TargetSpawnSystemSettings.self))
    
    init(scene: AdaEngine.Scene) {}
    
    func update(context: UpdateContext) {
        if Game.isPaused { return }
        
        guard let directorEntity = context.scene.performQuery(Self.difficulty).first else {
            return
        }
        
        var difficulty = directorEntity.components[DifficultyComponent.self]!
        difficulty.currentTimer += context.deltaTime
        defer { directorEntity.components += difficulty }
        
        guard difficulty.levels.count != difficulty.levelIndex + 1 else {
            return
        }
        
        /// increase level
        if difficulty.currentTimer > difficulty.levels[difficulty.levelIndex + 1].time {
            difficulty.levelIndex += 1
            let level = difficulty.levels[difficulty.levelIndex]
            difficulty.currentLevel = level
            
            context.scene.performQuery(Self.targetSpawner).forEach { entity in
                var settings = entity.components[TargetSpawnSystemSettings.self]!
                settings.maxTargets = level.maxTargets
                entity.components += settings
            }
        }
    }
}
