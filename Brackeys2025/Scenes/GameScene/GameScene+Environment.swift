//
//  GameScene+Environment.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

extension GameScene {
    func setupLevel() {
        self.generateGrass()
        self.generateTerrain()
        
        self.addEntity(
            Entity(name: "Duck Hunt Logo") {
                SpriteComponent(texture: self.logo)
                Transform(rotation: .identity, scale: [14, 12, 12], position: [0, 12.5, -0])
            }
        )
        
        self.clouds()
        self.borders()
    }
    
    private func clouds() {
        for index in (0..<Int.random(in: 10..<12)) {
            let scale = Float.random(in: 0.7..<1.3)
            
            self.addEntity(
                Entity(name: "Cloud \(index)") {
                    Transform(
                        scale: Vector3(scale),
                        position: [
                            Float.random(in: -15..<15),
                            Float.random(in: 5..<15),
                            0
                        ]
                    )
                    
                    SpriteComponent(
                        texture: miscAtlas[2, 4]
                    )
                }
            )
        }
    }
    
    private func borders() {
        self.addEntity(
            Entity(name: "Top Border") {
                BorderComponent()
                
                Collision2DComponent(
                    shapes: [.generateBox()],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
                
                Transform(rotation: .identity, scale: [30, 1, 1], position: [0, 20, 0])
            }
        )
        
        self.addEntity(
            Entity(name: "Left Border") {
                BorderComponent()
                
                Collision2DComponent(
                    shapes: [.generateBox()],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
                
                Transform(rotation: .identity, scale: [6, 40, 1], position: [-15, 0, 0])
            }
        )
        
        self.addEntity(
            Entity(name: "Right Border") {
                BorderComponent()
                
                Collision2DComponent(
                    shapes: [.generateBox()],
                    mode: .default,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
                
                Transform(rotation: .identity, scale: [6, 40, 1], position: [15, 0, 0])
            }
        )
        
        self.addEntity(
            Entity(name: "Botton Border") {
                BorderComponent()
                DeathComponent()
                
                Collision2DComponent(
                    shapes: [.generateBox()],
                    mode: .trigger,
                    filter: CollisionFilter(
                        categoryBitMask: .obstacles,
                        collisionBitMask: .player
                    )
                )
                
                Transform(rotation: .identity, scale: [30, 6, 1], position: [0, -10.5, 0])
            }
        )
    }
    
    private func generateGrass() {
        var position: Float = -12
        for index in 0..<26 {
            self.addEntity(
                Entity(name: "Grass \(index)") {
                    SpriteComponent(
                        texture: miscAtlas[Int.random(in: 0...1), 4]
                    )
                    Transform(
                        rotation: .identity,
                        scale: [1, 1, 1],
                        position: [position, -7, 0]
                    )
                }
            )
            
            position += 1
        }
    }
    
    private func generateTerrain() {
        self.addEntity(
            Entity(name: "Terrain") {
                SpriteComponent(tintColor: Game.groundColor)
                Transform(rotation: .identity, scale: [26, 6, 1], position: [0, -10.5, 0])
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
        
        var position: Float = -12
        for _ in 0..<26 {
            self.addEntity(
                Entity(name: "Terrain") {
                    SpriteComponent(
                        texture: miscAtlas[Int.random(in: 3...4), 4]
                    )
                    Transform(
                        rotation: .identity,
                        scale: [1, 1, 1],
                        position: [position, -8, 1]
                    )
                }
            )
            
            position += 1
        }
    }
}

@Component
struct BorderComponent {}

@Component
struct DeathComponent {}
