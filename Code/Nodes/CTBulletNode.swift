//
//  CTBulletNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/26/24.
//

import SpriteKit

class CTBulletNode: SKSpriteNode {
    
    init(imageNamed: String, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed )
        texture.filteringMode = .nearest
        super.init(texture: texture, color: .clear, size: size)
        
        enablePhysics()
    }
    
    func enablePhysics(){
        if(physicsBody == nil){
            physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.0)
            physicsBody?.isDynamic = true
            physicsBody?.affectedByGravity = false
            physicsBody?.mass = 0.05
            physicsBody?.friction = 0
            physicsBody?.categoryBitMask = CTPhysicsCategory.bullet
            physicsBody?.contactTestBitMask = CTPhysicsCategory.car | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck | CTPhysicsCategory.ped | CTPhysicsCategory.building
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not implemented")
    }
}
