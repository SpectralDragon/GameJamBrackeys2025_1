//
//  PlayerMovementDashIndicator.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 20.02.2025.
//

import AdaEngine

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
        guard let window = context.scene.window else {
            return
        }
        
        context.scene.performQuery(Self.player).forEach { player in
            let impulseArrow = player.components[PlayerImpulseArrow.self]!
            
            guard let rawStartPosition = impulseArrow.startPosition else {
                return
            }
            
            var renderContext = UIGraphicsContext(window: window)
            renderContext.beginDraw(in: window.frame.size, scaleFactor: 1)
            defer { renderContext.commitDraw() }
            
            let mousePosition = Input.getMousePosition()
            let startPosition = Vector2(rawStartPosition.x, rawStartPosition.y)
            let endPosition = Vector2(mousePosition.x, -mousePosition.y)
            
            renderContext.drawLine(start: startPosition, end: endPosition, lineWidth: 10, color: .red)
        }
    }
}
