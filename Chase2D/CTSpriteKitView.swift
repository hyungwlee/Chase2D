//
//  CTSpriteKitView.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/27/24.
//

import SwiftUI
import SpriteKit

struct CTSpriteKitView: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
//        skView.showsPhysics = true // Enable physics debug outlines
        skView.showsFPS = true     // Optional: Show FPS
        skView.showsNodeCount = true // Optional: Show node count
//        skView.presentScene(scene)  // Set the scene
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.presentScene(scene) // Update scene if needed
    }
}
