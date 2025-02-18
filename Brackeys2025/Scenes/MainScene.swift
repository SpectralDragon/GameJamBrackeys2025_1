//
//  ContentView.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 17.02.2025.
//

import AdaEngine

struct ComponentView: View {

    @Environment(\.scene) var scene
    @State var isPreview = false

    var body: some View {
        Button("Go to next screen") {
            scene?.sceneManager?.presentScene(GameScene())
        }
        .foregroundColor(.white)
        .background(.blue)
    }
}

class MainScene: Scene {
    override func sceneDidLoad() {
        self.addEntity(
            Entity {
                UIComponent(
                    view: ComponentView(),
                    behaviour: .overlay
                )
            }
        )
    }
}
