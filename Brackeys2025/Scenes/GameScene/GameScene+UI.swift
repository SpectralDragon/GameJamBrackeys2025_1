//
//  GameScene+UI.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 22.02.2025.
//

import AdaEngine

struct GameSceneUI: View {
    
    @State private var gameState: GameState = .idle
    @State private var timeInterval: TimeInterval = 0
    
    let font: Font
    
    var body: some View {
        VStack(alignment: .center) {
            switch gameState {
            case .idle:
                StartOverlayView()
            case .playing:
                PlayingOverlayView(timeInteval: $timeInterval)
                    .offset(x: 100)
            case .gameOver(let gameOver):
                YouDiedView(totalTime: timeInterval, gameOver: gameOver)
                    .offset(x: 200)
            }
        }
        .font(self.font)
        .padding(.all, 16)
        .onEvent(GameEvents.OnStateChange.self) { event in
            self.gameState = event.state
        }
    }
}

struct StartOverlayView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("Flight!")
            
            Text("Use your mouse to swipe in direction")
            
            Spacer()
        }
    }
}

struct PlayingOverlayView: View {
    
    @Binding var timeInteval: TimeInterval
    
    var body: some View {
        VStack {
            Text("SURVIVE!!!")
                .fontSize(52)
                .offset(x: 50)
                
            Spacer()
            
            Text("Timer: \(timeInteval)")
        }
        .onEvent(EngineEvents.GameLoopBegan.self) { event in
            timeInteval += event.deltaTime
        }
    }
}

struct YouDiedView: View {
    
    let totalTime: TimeInterval
    let gameOver: GameOver
    
    @Environment(\.scene) private var scene
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("You Died")
                .fontSize(76)
                .padding(.bottom, 16)
            
            Text("Total time: ") + Text("\(totalTime)")
            
            Text("Total bullet fired: ") + Text("\(gameOver.statistics.bulletFired)")
            
            Text("Total items collected: ") + Text("\(gameOver.statistics.itemsCollected)")
            
            Text("Press [space] to restart")
                .padding(.top, 16)
            
            Spacer()
        }
        .onEvent(EngineEvents.GameLoopBegan.self) { event in
            // FIXME: Hah
            if Input.isKeyPressed(.space) {
                self.scene?.sceneManager?.presentScene(GameScene())
            }
        }
    }
}

extension GameScene {
    func setupUI() {
        self.addEntity(
            Entity(name: "OverlayUI") {
                UIComponent(
                    view: GameSceneUI(font: self.font),
                    behaviour: .overlay
                )
            }
        )
    }
}
