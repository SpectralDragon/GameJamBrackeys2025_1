//
//  GameScene.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 18.02.2025.
//

import AdaEngine

class GameScene: Scene {
    override func sceneDidLoad() {
        let camera = OrthographicCamera()
        self.addEntity(camera)

        self.addEntity(
            Entity {
                SpriteComponent(tintColor: .red)
                Transform(rotation: .identity, scale: .one, position: .zero)
            }
        )
    }
}
