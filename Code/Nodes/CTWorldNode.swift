//
//  WorldNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import SpriteKit

class CTWorldNode: SKSpriteNode{
    init(){
        let texture = SKTexture(imageNamed: "World")
        texture.filteringMode = .nearest
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemended")
    }
    
    func setup(screenSize: CGSize){
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        physicsBody = SKPhysicsBody()
        physicsBody?.isDynamic = false
        physicsBody?.friction = 0.5
    }
}
