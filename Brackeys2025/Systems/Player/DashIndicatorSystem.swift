//
//  DashIndicatorSystem.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

@Component
struct DashIndicator {
    var maxDashCount: Int
    var currentDashCount: Int
    var dashCooldown: LongTimeInterval = 3.5
    var lastDashUsage: LongTimeInterval = 0
    var dashTexture: Texture2D
    
    init(
        maxDashCount: Int,
        dashCooldown: LongTimeInterval,
        dashTexture: Texture2D
    ) {
        self.maxDashCount = maxDashCount
        self.currentDashCount = maxDashCount
        self.dashCooldown = dashCooldown
        self.lastDashUsage = 0
        self.dashTexture = dashTexture
    }
    
    mutating func useDash() {
        self.currentDashCount -= 1
        self.lastDashUsage = Time.absolute
    }
}

@Component
private struct DashIndicatorItem {
    let index: Int
}

struct DashIndicatorSystem: System {
    
    static var dashIndicator = EntityQuery(where: .has(DashIndicator.self))
    static var dashIndicatorItem = EntityQuery(where: .has(DashIndicatorItem.self))
    
    init(scene: AdaEngine.Scene) { }
    
    func update(context: UpdateContext) {
        context.scene.performQuery(Self.dashIndicator).forEach { entity in
            var dashIndicator = entity.components[DashIndicator.self]!
            
            self.updateDashIndicators(
                in: context,
                dashIndicator: dashIndicator,
                parent: entity
            )
            
            if dashIndicator.maxDashCount == dashIndicator.currentDashCount {
                return
            }
            
            if Time.absolute - dashIndicator.dashCooldown < dashIndicator.lastDashUsage {
                return
            }
            
            dashIndicator.lastDashUsage = Time.absolute
            dashIndicator.currentDashCount += 1
            entity.components += dashIndicator
        }
    }
}

private extension DashIndicatorSystem {
    @MainActor
    func updateDashIndicators(
        in context: UpdateContext,
        dashIndicator: DashIndicator,
        parent: Entity
    ) {
        if parent.children.count < dashIndicator.maxDashCount {
            let maxDashCount = -(Float(dashIndicator.maxDashCount) * 0.25) / 2
            
            (0..<dashIndicator.currentDashCount).forEach { index in
                let indicator = Entity(name: "DashIndicator \(index)") {
                    Transform(
                        scale: [0.3, 0.3, 0.3],
                        position: [maxDashCount + 0.35 * Float(index), 0, 0]
                    )
                    SpriteComponent(texture: dashIndicator.dashTexture)
                    NoFrustumCulling()
                    DashIndicatorItem(index: index)
                }
                
                context.scene.addEntity(indicator)
                parent.addChild(indicator)
            }
        }
       
        context.scene.performQuery(Self.dashIndicatorItem).forEach { entity in
            let indicator = entity.components[DashIndicatorItem.self]!
            
            let isVisible = indicator.index < dashIndicator.currentDashCount
            entity.components[SpriteComponent.self]?.tintColor = isVisible ? .white : .gray.opacity(0.3)
        }
    }
}
