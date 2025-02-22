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
    
    static let dashRenderIndicator = EntityQuery(
        where: .has(DashRenderIndicator.self)
    )
    
    private let forceMultiplier: Float = 2
    private let forceRestriction: Float = 120
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        #if DEBUG
        guard let cameraEntity = context.scene.performQuery(Self.camera).first else {
            assertionFailure("Can't find required camera")
            return
        }
        
        cameraControl(cameraEntity, deltaTime: context.deltaTime)
        #endif
        
        context.scene.performQuery(Self.player).forEach { player in
            
            let dashIndicatorEntity = context.scene.performQuery(Self.dashIndicator).first
            guard var dashIndicator = dashIndicatorEntity?.components[DashIndicator.self] else {
                print("No DashIndicator")
                return
            }
            
            var (playerComponent, physicsBody, impulseArrow) = player.components[
                PlayerComponent.self,
                PhysicsBody2DComponent.self,
                PlayerImpulseArrow.self
            ]
            let rawMousePosition = Input.getMousePosition()
            let mousePosition = Vector2(rawMousePosition.x, -rawMousePosition.y)
            
            playerComponent.direction = physicsBody.linearVelocity
            player.components += playerComponent
            
            guard dashIndicator.currentDashCount > 0 else {
                return
            }
            
            if Input.isMouseButtonPressed(.left) {
                if impulseArrow.startPosition == nil {
                    impulseArrow.startPosition = mousePosition
                    self.spawnDashIndicator(at: mousePosition, context: context)
                }
            } else {
                if let startPosition = impulseArrow.startPosition {
                    let endPositionVector = mousePosition
                    
                    // If start and end position are the same, then stop the movement
                    if startPosition == endPositionVector {
                        impulseArrow.startPosition = nil
                        return
                    }
                        
                    let direction = endPositionVector - startPosition
                    let swipeMagnitude = direction.magnitudeSquared / 2
                    let forceDirection = direction.normalized
                    
                    let force = forceDirection * Float(swipeMagnitude) * forceMultiplier
                    
                    physicsBody.clearForces()
                    physicsBody.applyForce(
                        force: Vector2(
                            clamp(force.x, -forceRestriction, forceRestriction),
                            clamp(force.y, -forceRestriction, forceRestriction)
                        ),
                        point: .zero,
                        wake: true
                    )
                    impulseArrow.startPosition = nil
                    dashIndicator.useDash()
                    self.dispawnDashIndicator(context: context)
                    dashIndicatorEntity?.components += dashIndicator
                }
            }
            
            player.components += impulseArrow
        }
    }
}

private extension PlayerMovementSystem {
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
        let entity = Entity(name: "DashRenderIndicator") {
            Transform(rotation: .identity, scale: [2, 0.5, 1], position: [position.x, position.y, 0])
            SpriteComponent(tintColor: .red)
            DashRenderIndicator()
        }
        
        context.scene.addEntity(entity)
    }
    
    private func dispawnDashIndicator(context: UpdateContext) {
        context.scene.performQuery(Self.dashRenderIndicator).forEach {
            context.scene.removeEntity($0)
        }
    }
}
