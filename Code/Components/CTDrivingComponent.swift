//
//  CTDrivingComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit

class CTDrivingComponent: GKComponent {
    
    let carNode: SKSpriteNode
    var MOVE_FORCE:CGFloat = 1300
    var hasStopped = false
    var isRamming = false
   
    enum driveDir {
        case forward
        case backward
        case none
    }
    
    init(carNode: SKSpriteNode) {
        self.carNode = carNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    func drive(driveDir: driveDir){
        
        guard let physicsBody = carNode.physicsBody else {return}
       
        if (driveDir == .backward){
            
            if((physicsBody.velocity.dx * physicsBody.velocity.dx + physicsBody.velocity.dy * physicsBody.velocity.dy) > 700 &&
             !hasStopped){
                self.carNode.physicsBody?.linearDamping = 1.0
                self.carNode.physicsBody?.angularVelocity = 0.0
            } else {
                hasStopped = true
                self.carNode.physicsBody?.linearDamping = 10.0
                let directionX = -sin(self.carNode.zRotation) * MOVE_FORCE * 30
                let directionY = cos(self.carNode.zRotation) * MOVE_FORCE * 30
                let force = CGVector(dx: -directionX, dy: -directionY)
                self.carNode.physicsBody?.applyForce(force)
            }
            
        }else if(driveDir == .forward){
            
            hasStopped = false
            self.carNode.physicsBody?.linearDamping = 10.0
            
            let directionX = -sin(self.carNode.zRotation) * MOVE_FORCE * 70
            let directionY = cos(self.carNode.zRotation) * MOVE_FORCE * 70
            let force = CGVector(dx: directionX, dy: directionY)
            self.carNode.physicsBody?.applyForce(force)
        }
       
    }
    
    func ram(){
        if isRamming {return}
        // timer
        let wait = SKAction.wait(forDuration: 0.05)
        let run = SKAction.run {
            self.isRamming = true
            self.MOVE_FORCE = self.MOVE_FORCE * 1.3
        }
        let end = SKAction.run{
            self.MOVE_FORCE = self.MOVE_FORCE / 1.3
        }
        let wait2 = SKAction.wait(forDuration: 2)
        let reset = SKAction.run{
            self.isRamming = false
        }
        
        let sequence = SKAction.sequence([run, wait, end, wait2, reset])
        self.carNode.run(sequence)
    }
    
}
