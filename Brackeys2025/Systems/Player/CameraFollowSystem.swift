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
    
    private let cameraOffset: Vector3 = [0, 0, 0]
    private let speed: Float = 1
    private let bounds: Rect = Rect(x: -3, y: -5,
                                    width: 3, height: 15)
    
    static var dependencies: [SystemDependency] = [
        .after(Physics2DSystem.self),
        .after(PlayerMovementSystem.self)
    ]
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        guard let camera = context.scene.performQuery(Self.cameras).first else {
            assertionFailure("Camera not found in scene")
            return
        }
        
        guard let player = context.scene.performQuery(Self.player).first else {
            return
        }
        
        let playerTransform = player.components[Transform.self]!
        var cameraTransform = camera.components[Transform.self]!
        
        var targetPosition = lerp(
            cameraTransform.position,
            playerTransform.position + cameraOffset,
            speed * context.deltaTime
        )
        
        targetPosition.x = clamp(targetPosition.x, bounds.minX, bounds.width)
        targetPosition.y = clamp(targetPosition.y, bounds.minY, bounds.height)
        cameraTransform.position = targetPosition
        camera.components += cameraTransform
    }
}
