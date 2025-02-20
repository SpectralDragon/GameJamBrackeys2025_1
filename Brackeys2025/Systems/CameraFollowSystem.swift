//
//  CameraFollowSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 19.02.2025.
//

import AdaEngine

@Component
struct CameraFollowing {}

struct CameraFollowSystem: System {
    
    static let cameras = EntityQuery(where: .has(Camera.self) && .has(Transform.self))
    static let player = EntityQuery(where: .has(PlayerComponent.self) && .has(Transform.self))
    
    private let cameraOffset: Vector3 = [0, 1, 0]
    private let speed: Float = 0.7
    
    static var dependencies: [SystemDependency] = [
        .after(Physics2DSystem.self)
    ]
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        guard let camera = context.scene.performQuery(Self.cameras).first else {
            assertionFailure("Camera not found in scene")
            return
        }
        
        guard let player = context.scene.performQuery(Self.player).first else {
            assertionFailure("Player not found in scene")
            return
        }
        
        let playerTransform = player.components[Transform.self]!
        var cameraTransform = camera.components[Transform.self]!
        cameraTransform.position = lerp(
            cameraTransform.position,
            playerTransform.position + cameraOffset,
            speed * context.deltaTime
        )
        camera.components[Transform.self] = cameraTransform
    }
}
