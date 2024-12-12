//
//  CTSmokeParticle.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/11/24.
//

import SpriteKit

class CTSmokeParticle: SKNode {
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func particleSystemUpdate() {
        
        let smokeParticle = SKShapeNode(rectOf: CGSize(width: 2.0, height: 2.0))
        smokeParticle.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        smokeParticle.strokeColor = .clear
        
        smokeParticle.alpha = 0.5 // Start fully opaque
        smokeParticle.position = CGPoint(x: position.x, y: position.y - 5.0)
        smokeParticle.zPosition = 0

        // Add a physics body for random movement
        smokeParticle.physicsBody = SKPhysicsBody(circleOfRadius: 0.5) // Match size
        smokeParticle.physicsBody?.affectedByGravity = false
        smokeParticle.physicsBody?.linearDamping = 0.8 // Slow down over time
        smokeParticle.physicsBody?.angularDamping = 0.8
        smokeParticle.physicsBody?.collisionBitMask = CTPhysicsCategory.none // No collisions
        smokeParticle.physicsBody?.contactTestBitMask = CTPhysicsCategory.none // No collisions
        smokeParticle.physicsBody?.categoryBitMask = CTPhysicsCategory.none // No collisions

        // Apply random initial velocity
        let randomX = CGFloat.random(in: -10...10)
        let randomY = CGFloat.random(in: -10...10) // Drift upwards
        smokeParticle.physicsBody?.velocity = CGVector(dx: randomX, dy: randomY)

        // Apply random rotation
        smokeParticle.zRotation = CGFloat.random(in: 0...(2 * .pi))

        addChild(smokeParticle)

        // Add actions for fading, shrinking, and removing
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let scaleDown = SKAction.scale(to: 2, duration: 0.25)
        let rotate = SKAction.rotate(byAngle: .pi / 6.0 , duration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([fadeOut, scaleDown, rotate]), remove])
        smokeParticle.run(sequence)
    }
    
}
