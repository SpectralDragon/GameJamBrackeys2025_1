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
//        cameraTransform.position.z = playerTransform.position.z
//        let targetDirection = (playerTransform.position - cameraTransform.position);
//        let interpVelocity = targetDirection.magnitudeSquared * 5;
//        
//        let targetPos = cameraTransform.position + (targetDirection.normalized * interpVelocity * context.deltaTime);
//        cameraTransform.position = Math.lerp()//Vector3.Lerp( transform.position, targetPos + offset, 0.25f);
        
        cameraTransform.position.x = playerTransform.position.x
        cameraTransform.position.y = playerTransform.position.y
        camera.components[Transform.self] = cameraTransform
    }
}
