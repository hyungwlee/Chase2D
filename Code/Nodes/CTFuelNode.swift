//
//  CTFuelNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/6/24.
//

import SpriteKit

class CTFuelNode: SKSpriteNode {
    
    init(imageNamed: String, nodeSize: CGSize){
        let texture = SKTexture(imageNamed: imageNamed)
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: nodeSize)
        enablePhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not found!")
    }
    
    func enablePhysics(){
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CTPhysicsCategory.fuel
        self.physicsBody?.contactTestBitMask = CTPhysicsCategory.car
        self.physicsBody?.collisionBitMask = CTPhysicsCategory.none
    }
    
    
    
}
