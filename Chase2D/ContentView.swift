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
    
    init(){
        if let loadedScene = SKScene(fileNamed: "CTGameScene") as? CTGameScene {
            loadedScene.context = context
            loadedScene.size = screenSize
            self.scene = loadedScene
            
        }else{
            self.scene = SKScene(size: screenSize)
        }

    }
    var body: some View {
        VStack{
            CTSpriteKitView(scene: self.scene)
        }
        
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .ignoresSafeArea()
                .statusBarHidden()
        }
    }
}
