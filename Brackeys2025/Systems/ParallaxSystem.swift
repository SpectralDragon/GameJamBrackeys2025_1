//
//  ParallaxSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 21.02.2025.
//

import AdaEngine

@Component
struct Parallax {
    var speed: Float
    var offset: Float
}

struct ParallaxSystem: System {
    
    static let cameras = EntityQuery(where: .has(Camera.self) && .has(Transform.self))
    static let parallax = EntityQuery(where: .has(Parallax.self) && .has(Transform.self))
    
    init(scene: Scene) { }
    
    func update(context: UpdateContext) {
        guard let camera = context.scene.performQuery(Self.cameras).first else {
            assertionFailure("Camera not found in scene")
            return
        }
        
        guard let parallax = context.scene.performQuery(Self.parallax).first else {
            return
        }
        
        let cameraTransform = camera.components[Transform.self]!
        var parallaxTransform = parallax.components[Transform.self]!
        
        let cameraPosition = cameraTransform.position
        let parallaxPosition = parallaxTransform.position
        
        let distance = cameraPosition.x - parallaxPosition.x
        let parallaxComponent = parallax.components[Parallax.self]!
        
        let parallaxSpeed = parallaxComponent.speed
        let parallaxOffset = parallaxComponent.offset
        
        parallaxTransform.position.x = cameraPosition.x - distance * parallaxSpeed + parallaxOffset
        parallax.components[Transform.self] = parallaxTransform
    }
}
