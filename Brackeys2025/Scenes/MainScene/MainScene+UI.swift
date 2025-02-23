//
//  MainScene+UI.swift
//  Brackeys2025
//
//  Created by Vladislav Prusakov on 23.02.2025.
//

import AdaEngine
 
enum MainMenuState {
    case menu
    case story
    case tutorial
}

struct MainView: View {
    
    let font: Font

    @Environment(\.scene) var scene
    @State private var fixedTime = FixedTimestep(stepsPerSecond: 12)
    @State var state: MainMenuState = .menu
    @State private var currentStoryLineIndex: Int = 0

    var body: some View {
        VStack {
            switch state {
            case .menu:
                Text("Press [space] to next")
            case .story:
                StoryLineView(currentState: $currentStoryLineIndex)
            case .tutorial:
                Text("Press [space] to next")
            }
        }
        .onEvent(EngineEvents.GameLoopBegan.self) { event in
            let advance = fixedTime.advance(with: event.deltaTime)
            
            if !advance.isFixedTick || advance.fixedTime < 1 / 12 {
                return
            }
            
            if Input.isKeyPressed(.space) {
                onSpaceBarPressed()
            }
        }
        .font(self.font)
        .padding(.all, 16)
    }
    
    private func onSpaceBarPressed() {
        switch state {
        case .menu:
            state = .story
        case .story:
            if currentStoryLineIndex < MainScene.story.count - 1 {
                currentStoryLineIndex += 1
                print(currentStoryLineIndex)
            } else {
                state = .tutorial
            }
        case .tutorial:
            scene?.value?.clearAllEntities()
            scene?.value?.sceneManager?.presentScene(GameScene())
        }
    }
}

struct StoryLineView: View {
    
    @Binding var currentState: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Spacer()
            Text(MainScene.story[currentState])
        }
    }
}

extension MainScene {
    func setupUI() {
        self.addEntity(
            Entity {
                UIComponent(
                    view: MainView(font: self.font),
                    behaviour: .overlay
                )
            }
        )
    }
}

private extension MainScene {
    static let story: [String] = [
        "Hey little duck. How are you?",
        "Today is very sunny, right?",
        "So, I want to tell you, that on the other\n side of river I hear burks",
        "I think, this place isn't safe anymore.",
        "Be careful."
    ]
}
