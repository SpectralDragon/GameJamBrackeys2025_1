//
//  ShootEffectSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine

@Component
struct ShootEffect {
    var lifetime: TimeInterval = 0.2
    var currentTime: TimeInterval = 0
    var cameraBackground: Color = .clear
}

struct ShootEffectSystem: System {
    
    static let camera = EntityQuery(where: .has(Camera.self))
    static let shoots = EntityQuery(where: .has(ShootEffect.self))
    
    init(scene: AdaEngine.Scene) {}
    
    func update(context: UpdateContext) {
        guard
            let cameraEntity = context.scene.performQuery(Self.camera).first,
            let camera = cameraEntity.components[Camera.self]
        else {
            return
        }
        
        guard let entity = context.scene.performQuery(Self.shoots).first else {
            return
        }
        
        defer {
            cameraEntity.components += camera
        }
        
        var effect = entity.components[ShootEffect.self]!
        effect.currentTime += context.deltaTime
        
        if effect.lifetime < effect.currentTime {
            camera.backgroundColor = effect.cameraBackground
            entity.removeFromScene()
            return
        }
        
        camera.backgroundColor = .white
        
        entity.components += effect
    }
}
