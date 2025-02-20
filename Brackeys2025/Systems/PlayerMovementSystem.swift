//
//  PlayerMovementSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 20.02.2025.
//

import AdaEngine

@Component
struct PlayerImpulseArrow {
    var startPosition: Vector2?
}

struct PlayerMovementSystem: System {
    
    static let player = EntityQuery(
        where: .has(PlayerComponent.self) && .has(Transform.self) &&
               .has(PhysicsBody2DComponent.self) && .has(PlayerImpulseArrow.self)
    )
    
    static let camera = EntityQuery(
        where: .has(Camera.self) && .has(Transform.self)
    )
    
    static let dashIndicator = EntityQuery(
        where: .has(DashIndicator.self)
    )
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        guard let cameraEntity = context.scene.performQuery(Self.camera).first else {
            assertionFailure("Can't find required camera")
            return
        }
        
        let camera = cameraEntity.components[Camera.self]!
        #if DEBUG
        cameraControl(cameraEntity, deltaTime: context.deltaTime)
        #endif
        
        context.scene.performQuery(Self.player).forEach { player in
            var (physicsBody, impulseArrow) = player.components[
                PhysicsBody2DComponent.self,
                PlayerImpulseArrow.self
            ]
            let mousePosition = Input.getMousePosition()
            
            if Input.isMouseButtonPressed(.left) {
                if impulseArrow.startPosition == nil {
                    let globalTransform = context.scene.worldTransformMatrix(for: cameraEntity)
                    if let position = camera.viewportToWorld2D(cameraGlobalTransform: globalTransform, viewportPosition: mousePosition) {
                        let vector = Vector2(position.x, -position.y)
                        print("Start:", vector)
                        impulseArrow.startPosition = vector
                        self.spawnDashIndicator(at: vector, context: context)
                    }
                }
            } else {
                if let startPosition = impulseArrow.startPosition {
                    let globalTransform = context.scene.worldTransformMatrix(for: cameraEntity)
                    let position = camera.viewportToWorld2D(
                        cameraGlobalTransform: globalTransform,
                        viewportPosition: mousePosition
                    ) ?? .zero
                    
                    let endPositionVector = Vector2(position.x, -position.y)
                    if startPosition == endPositionVector {
                        impulseArrow.startPosition = nil
                        return
                    }
                    
                    print("End:", endPositionVector)
                    let direction = (endPositionVector - startPosition).normalized * 100
                    print("Direction", endPositionVector)
                    //                    physicsBody.applyForce(force: direction, point: .zero, wake: true)
                    impulseArrow.startPosition = nil
                    
                    self.dispawnDashIndicator(context: context)
                    
                }
            }
            
            player.components += impulseArrow
        }
    }
    
#if DEBUG
    @MainActor
    func cameraControl(_ camera: Entity, deltaTime: Float) {
        if Input.isKeyPressed(.w) {
            camera.components[Transform.self]?.position.y += 1
        }
        
        if Input.isKeyPressed(.s) {
            camera.components[Transform.self]?.position.y -= 1
        }
        
        if Input.isKeyPressed(.a) {
            camera.components[Transform.self]?.position.x -= 1
        }
        
        if Input.isKeyPressed(.d) {
            camera.components[Transform.self]?.position.x += 1
        }
        
        if Input.isKeyPressed(.q) {
            camera.components[Camera.self]?.orthographicScale += 5 * deltaTime
        }
        
        if Input.isKeyPressed(.e) {
            camera.components[Camera.self]?.orthographicScale -= 5 * deltaTime
        }
    }
#endif
    
    @MainActor
    private func spawnDashIndicator(at position: Vector2, context: UpdateContext) {
        let entity = Entity(name: "DashIndicator") {
            Transform(rotation: .identity, scale: [2, 0.5, 1], position: [position.x, position.y, 0])
            SpriteComponent(tintColor: .red)
            DashIndicator()
        }
        
        context.scene.addEntity(entity)
    }
    
    private func dispawnDashIndicator(context: UpdateContext) {
        context.scene.performQuery(Self.dashIndicator).forEach {
            context.scene.removeEntity($0)
        }
    }
}
