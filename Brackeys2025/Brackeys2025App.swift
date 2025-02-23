//
//  Brackeys2025App.swift
//  Brackeys2025
//
//  Created by vladislav.prusakov on 17.02.2025.
//

import AdaEngine

@main
struct Brackeys2025App: App {
    var scene: some AppScene {
        GameAppScene {
            MainScene()
        }
        .windowMode(.windowed)
        .windowTitle("Holy Duck")
    }
}
