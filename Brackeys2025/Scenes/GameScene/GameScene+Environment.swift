//
//  GameScene+Environment.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

extension GameScene {
    func setupLevel() {
        self.addEntity(
            Entity(name: "Grass") {
                SpriteComponent(tintColor: .green)
                Transform(rotation: .identity, scale: [20, 1, 1], position: [0, -2, 0])
                Collision2DComponent(
                    shapes: [
                        .generateBox()
                    ],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
            }
        )
        
        self.addEntity(
            Entity(name: "Terrain") {
                SpriteComponent(tintColor: .brown)
                Transform(rotation: .identity, scale: [20, 6, 1], position: [0, -5.5, 0])
                Collision2DComponent(
                    shapes: [
                        .generateBox()
                    ],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
            }
        )
        
        self.addEntity(
            Entity(name: "Grass Layer 1") {
                SpriteComponent(tintColor: Color.gray)
                Transform(rotation: .identity, scale: [20, 1, 1], position: [0, -3.5, 0])
                Collision2DComponent(
                    shapes: [
                        .generateBox()
                    ],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
            }
        )
    }
}
