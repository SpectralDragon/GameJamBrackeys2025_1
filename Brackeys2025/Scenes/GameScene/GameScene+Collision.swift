//
//  GameScene+Collision.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

extension GameScene {
    func onCollisionBegan(
        _ entityA: Entity,
        _ entityB: Entity
    ) {
        if entityB.components.has(PlayerComponent.self) && entityA.components.has(TargetComponent.self) {
            self.onTriggerCollide(entityB, entityA)
            return
        }
        
        if entityB.components.has(PlayerComponent.self) && entityA.components.has(Bullet.self) {
            self.onBulletCollide(entityB, entityA)
            return
        }
        
        if entityB.components.has(PlayerComponent.self) && entityA.components.has(BonusItem.self) {
            self.onBonusItemCollide(entityB, entityA)
        }
    }
    
    private func onTriggerCollide(
        _ playerEntity: Entity,
        _ targetEntity: Entity
    ) {
        var targetComponent = targetEntity.components[TargetComponent.self]!
        if targetComponent.state != .catchTarget {
            targetComponent.state = .catchTarget
        }
        
        targetEntity.components += targetComponent
        targetEntity.components[Collision2DComponent.self]?.filter.collisionBitMask = []
    }
    
    private func onBulletCollide(
        _ playerEntity: Entity,
        _ targetEntity: Entity
    ) {
        guard let gameMaster else {
            return
        }
        
        let (difficulty, statistics) = gameMaster.components[DifficultyComponent.self, Statistics.self]
        let gameOver = GameOver(
            totalTime: difficulty.currentTimer,
            statistics: statistics
        )
        
        self.eventManager.send(
            GameEvents.OnStateChange(
                state: .gameOver(gameOver)
            )
        )
        
        Game.isPaused = true
    }
    
    private func onBonusItemCollide(
        _ playerEntity: Entity,
        _ bonusEntity: Entity
    ) {
        guard let gameMaster else {
            return
        }
        
        let bonus = bonusEntity.components[BonusItem.self]!
        defer {
            bonusEntity.removeFromScene()
        }
        gameMaster.components[Statistics.self]?.itemsCollected += 1
        
        let dashIndicatorEntity = playerEntity.children.first {
            $0.components.has(DashIndicator.self)
        }!
        var dashIndicator = dashIndicatorEntity.components[DashIndicator.self]!
        defer {
            dashIndicatorEntity.components += dashIndicator
        }
        
        switch bonus.type {
        case .cooldownReduced:
            dashIndicator.dashCooldown -= 0.2
            return
        case .addDash:
            dashIndicator.maxDashCount += 1
            dashIndicator.currentDashCount = dashIndicator.maxDashCount
            
            return
        case .infiniteDash:
            return
        case .slowMode:
            return
        }
    }
}
