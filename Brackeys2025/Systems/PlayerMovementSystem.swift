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

@Component
struct DashIndicator { }

struct PlayerMovementDashIndicator: System {
    
    static let player = EntityQuery(
        where: .has(Transform.self) && .has(PlayerImpulseArrow.self)
    )
    
    static let camera = EntityQuery(
        where: .has(Camera.self) && .has(Transform.self)
    )
    
    static let dashIndicator = EntityQuery(
        where: .has(DashIndicator.self) && .has(Transform.self)
    )
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        guard let cameraEntity = context.scene.performQuery(Self.camera).first else {
            assertionFailure("Can't find required component")
            return
        }
        
        guard let dashEntity = context.scene.performQuery(Self.dashIndicator).first else {
            return
        }
        
        var dashTransform = dashEntity.components[Transform.self]!
        let camera = cameraEntity.components[Camera.self]!
        
        context.scene.performQuery(Self.player).forEach { player in
            let impulseArrow = player.components[PlayerImpulseArrow.self]!
            
            guard let startPosition = impulseArrow.startPosition else {
                return
            }
            
            let mousePosition = Input.getMousePosition()
            let globalTransform = context.scene.worldTransformMatrix(for: cameraEntity)
            let position = camera.viewportToWorld2D(cameraGlobalTransform: globalTransform, viewportPosition: mousePosition) ?? .zero
            
            let endPositionVector = Vector2(position.x, -position.y)
            let direction = (endPositionVector - startPosition).normalized
            let length = (endPositionVector - startPosition).squaredLength / 2
            let angle = Math.atan2(direction.y, direction.x)
            
            let newPosition = (endPositionVector - startPosition / 2)
            dashTransform.position.x = newPosition.x
            dashTransform.position.y = newPosition.y
            dashTransform.scale = [length, 0.5, 1]
            dashTransform.rotation = Quat.euler([0, 0, -angle])
        }
        
        dashEntity.components += dashTransform
    }
}
