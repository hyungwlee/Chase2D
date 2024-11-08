//
//  CTCopAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/7/24.
//

import SpriteKit

class CTCopNode: CTPedCarNode {
    
    var player: CTCarNode?
    
    override init(imageNamed: String, size: CGSize){
       
        self.player = nil
        super.init(imageNamed: imageNamed, size: size)
       
        self.STEER_IMPULSE = 0.05
        self.MOVE_FORCE = 1200
        self.DRIFT_FORCE = 100
        self.DRIFT_VELOCITY_THRESHOLD = 6
        enablePhysics()
    }
    
    override func enablePhysics(){
        if(physicsBody == nil){
            physicsBody = SKPhysicsBody(rectangleOf: self.size)
        }
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 50 // Adjust for realistic movement
        physicsBody?.friction = 0
        physicsBody?.restitution = 1 // Controls bounciness
        physicsBody?.angularDamping = 24 // Dampen rotational movement
        physicsBody?.linearDamping = 10 // Dampen forward movement slightly
        physicsBody?.categoryBitMask = CTPhysicsCategory.enemy
        physicsBody?.collisionBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.enemy
        physicsBody?.contactTestBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.enemy
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drive(driveDir: CTCarNode.driveDir) {
        
        super.drive(driveDir: .forward)
       
        avoidObstacles()
        
        if player == nil { return }
        
        // extra code needed to be added because of inheritance
        // clean up using gameplaykit components
         
        currentTarget = player?.position ?? CGPoint(x: 0, y: 0)
        
        follow(target: currentTarget)
    }
}
