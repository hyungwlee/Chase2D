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
    
    var body: some View {
        SpriteView(scene: CTGameScene(context: context,
                                      size: screenSize))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

