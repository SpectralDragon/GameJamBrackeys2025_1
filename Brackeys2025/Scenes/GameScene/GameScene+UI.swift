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
    @State private var timeOffset: Double = 0
    
    let font: Font
    
    var body: some View {
        VStack(alignment: .center) {
            switch gameState {
            case .idle:
                StartOverlayView()
            case .playing:
                PlayingOverlayView(timeInterval: $timeInterval, timeOffset: $timeOffset)
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
    
    @Binding var timeInterval: TimeInterval
    @Binding var timeOffset: Double
    
    var body: some View {
        VStack {
            Text("SURVIVE!!!")
                .fontSize(52)
                .textRendered(AnimatedSineWaveOffsetRender(timeOffset: timeOffset))
                .offset(x: 50)
                
            Spacer()
            
            Text("Time: \(timeInterval)")
        }
        .onEvent(EngineEvents.GameLoopBegan.self) { event in
            timeInterval += event.deltaTime
            
            if timeOffset > 1_000_000_000_000 {
                timeOffset = 0 // Reset the time offset
            }
            timeOffset += 5
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
                self.scene?.value?.clearAllEntities()
                self.scene?.value?.sceneManager?.presentScene(GameScene())
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

// MARK: - TextRenderer

extension Text.Layout {
    var runs: some RandomAccessCollection<TextRun> {
        flatMap { line in
            line
        }
    }

    var flattenedRuns: some RandomAccessCollection<Glyph> {
        runs.flatMap { $0 }
    }
}

struct AnimatedSineWaveOffsetRender: TextRenderer {
    
    let timeOffset: Double // Time offset

    init(timeOffset: Double) {
        self.timeOffset = timeOffset
    }

    func draw(layout: Text.Layout, in context: inout UIGraphicsContext) {
        let count = layout.flattenedRuns.count // Count all RunSlices in the text layout
        let width = layout.first?.typographicBounds.rect.width ?? 0 // Get the width of the text line
        let height = layout.first?.typographicBounds.rect.height ?? 0 // Get the height of the text line
        // Iterate through each RunSlice and its index
        for (index, glyph) in layout.flattenedRuns.enumerated() {
            // Calculate the sine wave offset for the current character
            let offset = animatedSineWaveOffset(
                forCharacterAt: index,
                amplitude: Double(height) / 4, // Set amplitude to half the line height
                wavelength: Double(width),
                phaseOffset: timeOffset,
                totalCharacters: count
            )
            // Create a copy of the context and translate it
            var copy = context
            copy.translateBy(x: 0, y: Float(offset))
            // Draw the current RunSlice in the modified context
            copy.draw(glyph)
        }

        func animatedSineWaveOffset(
            forCharacterAt index: Int,
            amplitude: Double,
            wavelength: Double,
            phaseOffset: Double,
            totalCharacters: Int
        ) -> Double {
            let x = Double(index)
            let position = (x / Double(totalCharacters)) * wavelength
            let radians = ((position + phaseOffset) / wavelength) * 2 * .pi
            return Math.sin(radians) * amplitude
        }
    }
}

