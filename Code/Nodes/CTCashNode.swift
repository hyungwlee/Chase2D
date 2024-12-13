//
//  CTPowerUpNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/23/24.
//

import SpriteKit

class CTCashNode: SKSpriteNode {
    
    init(imageNamed: String, nodeSize: CGSize){
        let texture = SKTexture(imageNamed: imageNamed)
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: nodeSize)
        enablePhysics()
        
//        let pointLight = SKLightNode()
//        pointLight.categoryBitMask = 1 // Set a category for the light
//        pointLight.position = self.position // Position the light
//        pointLight.lightColor = .yellow // Color of the light
//        pointLight.falloff = 5.0
////        pointLight.ambientColor = .gray // Ambient light color
////        pointLight.shadowColor = .black // Color of the shadows
//        scene?.addChild(pointLight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not found!")
    }
    
    func enablePhysics(){
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CTPhysicsCategory.cash
        self.physicsBody?.contactTestBitMask = CTPhysicsCategory.car
        self.physicsBody?.collisionBitMask = CTPhysicsCategory.none
    }
    
    
    
}
