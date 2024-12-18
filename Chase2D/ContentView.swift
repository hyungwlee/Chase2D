//
//  ContentView.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/25/24.
//

import SwiftUI
import GameplayKit
import SpriteKit

struct ContentView: View {
    
    let context = CTGameContext(dependencies: .init(),
                                gameMode: .single)
    let screenSize: CGSize = UIScreen.main.bounds.size
    
    let scene: SKScene
    
    init()
    {
        context.stateMachine?.enter(CTStartMenuState.self)
        
        if let loadedScene = SKScene(fileNamed: "CTGameScene") as? CTGameScene {
            loadedScene.context = context
            loadedScene.size = screenSize
//            loadedScene.scaleMode = .resizeFill
            
            self.scene = loadedScene
//            self.scene.scaleMode = .resizeFill
            
        }else{
            self.scene = SKScene(size: screenSize)
        }

    }
    var body: some View {
//        VStack{
//            if context.stateMachine?.currentState is CTStartMenuState
//            {
//                
//                Button(action: play)
//                {
//                    Label("Play", systemImage: "gamecontroller.fill")
//                        .font(.headline)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            if context.stateMachine?.currentState is CTGamePlayState
//            {
//                Button(action: pause)
//                {
//                    Label("", systemImage: "pause.fill")
//                        .font(.headline)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .opacity(0.5)
//                }
//            }
//            if context.stateMachine?.currentState is CTGameIdleState
//            {
//                Button(action: play)
//                {
//                    Text("Resume")
//                        .font(.headline)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
            
            CTSpriteKitView(scene: self.scene)
//        }
        
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .ignoresSafeArea()
                .statusBarHidden()
        }
    }
    
    func play()
    {
        context.stateMachine?.enter(CTGamePlayState.self)
    }
    func pause()
    {
        context.stateMachine?.enter(CTGameIdleState.self)
    }
}
