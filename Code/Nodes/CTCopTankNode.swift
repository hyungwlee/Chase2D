//
//  CTCopTankNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/28/24.
//

import SpriteKit

class CTCopTankNode: SKSpriteNode, EnemyNode, DriveableNode {
    var health: CGFloat = 100.0
    
    init(imageNamed: String, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed )
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: size)
        enablePhysics()
    }
    
    func enablePhysics(){
       
        if physicsBody == nil {
//            physicsBody = SKPhysicsBody(texture: self.texture ?? SKTexture(imageNamed: "black"), size: self.size)
            physicsBody = SKPhysicsBody(rectangleOf: self.size)
        }
        
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 300 // Adjust for realistic movement
        physicsBody?.friction = 0
        physicsBody?.restitution = 0.5 // Controls bounciness
        physicsBody?.angularDamping = 24 // Dampen rotational movement
        physicsBody?.linearDamping = 10 // Dampen forward movement slightly
        physicsBody?.categoryBitMask = CTPhysicsCategory.copTank
        physicsBody?.collisionBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck
        physicsBody?.contactTestBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped  | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

