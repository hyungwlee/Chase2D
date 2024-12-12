//
//  CTCopNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/3/24.
//

import SpriteKit

class CTCopNode: SKSpriteNode, EnemyNode, DriveableNode {
    var health: CGFloat = 10
    
    init(imageName: String, size: CGSize) {
        let texture = SKTexture(imageNamed: imageName)
        texture.filteringMode = .nearest
        super.init(texture: texture, color: .clear, size: size)
        enablePhysics()
        zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not set")
    }
    
    func enablePhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2.0)
       
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 5 // Adjust for realistic movement
        physicsBody?.friction = 0
        physicsBody?.restitution = 1 // Controls bounciness
        physicsBody?.angularDamping = 5 // Dampen rotational movement
        physicsBody?.linearDamping = 5 // Dampen forward movement slightly
        physicsBody?.categoryBitMask = CTPhysicsCategory.cop
        physicsBody?.collisionBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck | CTPhysicsCategory.cop
        physicsBody?.contactTestBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck | CTPhysicsCategory.cop
        
        
    }
    
}

