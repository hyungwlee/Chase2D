//
//  CTCopAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/7/24.
//

import SpriteKit

class CTCopNode: SKSpriteNode, EnemyNode, DriveableNode {
    var health: CGFloat = 50.0
    
    var frontLeftWheel = SKSpriteNode(color: .clear, size: CGSize(width: 1.0, height: 1.0))
    var frontRightWheel = SKSpriteNode(color: .clear, size: CGSize(width: 1.0, height: 1.0))
    var rearLeftWheel = SKSpriteNode(color: .clear, size: CGSize(width: 1.0, height: 1.0))
    var rearRightWheel = SKSpriteNode(color: .clear, size: CGSize(width: 1.0, height: 1.0))
    
    init(imageNamed: String, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed )
        texture.filteringMode = .nearest
       
        super.init(texture: texture, color: .clear, size: size)
         
        frontLeftWheel.position = CGPoint(x: -2.5, y: 6)
        frontRightWheel.position = CGPoint(x: 2.5, y: 6)
        rearLeftWheel.position = CGPoint(x: -2.5, y: -6)
        rearRightWheel.position = CGPoint(x: 2.5, y: -6)
        
        addChild(frontLeftWheel)
        addChild(frontRightWheel)
        addChild(rearLeftWheel)
        addChild(rearRightWheel)
        
        enablePhysics()
        addLights()
    }
    
    func enablePhysics(){
       
        if physicsBody == nil {
//            physicsBody = SKPhysicsBody(texture: self.texture ?? SKTexture(imageNamed: "black"), size: self.size)
            physicsBody = SKPhysicsBody(rectangleOf: self.size)
        }
        
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 50 // Adjust for realistic movement
        physicsBody?.friction = 0
        physicsBody?.restitution = 1 // Controls bounciness
        physicsBody?.angularDamping = 15 // Dampen rotational movement
        physicsBody?.linearDamping = 10 // Dampen forward movement slightly
        physicsBody?.categoryBitMask = CTPhysicsCategory.copCar
        physicsBody?.collisionBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck
        physicsBody?.contactTestBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped  | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck
    }
    
    func addLights() {
        let lights = CTCopLights(offset: CGPoint(x: 0.0, y: -1.0), size: CGSize(width: 4.5, height: 1.5))
        self.addChild(lights)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
