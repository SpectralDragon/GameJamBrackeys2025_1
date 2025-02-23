//
//  GameScene+GameMaster.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

extension GameScene {
    func setupGameMaster() {
        let gameMaster = Entity(name: "Game Master") {
            DifficultyComponent(
                levels: [
                    DifficultyLevel(
                        time: 0,
                        maxTargets: 1,
                        targetSpeed: 0.6,
                        bulletSpeed: 0.5,
                        availableItems: [
                            .addDash
                        ]
                    ),
                    DifficultyLevel(
                        time: .random(in: 35..<55),
                        maxTargets: 2,
                        targetSpeed: 0.8,
                        bulletSpeed: 0.8,
                        availableItems: [
                            .cooldownReduced,
                            .addDash
                        ]
                    ),
                    DifficultyLevel(
                        time: .random(in: 70..<95),
                        maxTargets: 4,
                        targetSpeed: 1,
                        bulletSpeed: 1,
                        availableItems: [
                            .cooldownReduced,
                            .addDash,
                            .infiniteDash
                        ]
                    ),
                    DifficultyLevel(
                        time: .random(in: 100..<125),
                        maxTargets: 6,
                        targetSpeed: 1.3,
                        bulletSpeed: 1.3,
                        availableItems: [
                            .cooldownReduced,
                            .addDash,
                            .infiniteDash,
                            .slowMode
                        ]
                    )
                ]
            )
            
            Statistics()
            
            ItemSpawnSettingsComponent(
                items: [
                    BonusItem(
                        type: .cooldownReduced,
                        permanent: true,
                        texture: miscAtlas[0, 0]
                    ),
                    BonusItem(
                        type: .addDash,
                        permanent: true,
                        texture: miscAtlas[0, 0]
                    ),
                    BonusItem(
                        type: .infiniteDash,
                        permanent: true,
                        texture: characters[1, 1]
                    ),
                    BonusItem(
                        type: .slowMode,
                        permanent: true,
                        texture: characters[0, 0]
                    )
                ]
            )
        }
        
        self.gameMaster = gameMaster
        self.addEntity(gameMaster)
    }
}
