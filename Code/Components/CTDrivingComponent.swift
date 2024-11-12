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
        
        var moveDir = 0.0
       
        switch driveDir {
        case .forward:
            moveDir = 1.0
            break
        case .backward:
            moveDir = -1.0
            break
        case .none:
            moveDir = 0.0
        }
       
        let directionX = -sin(self.carNode.zRotation) * MOVE_FORCE * moveDir
        let directionY = cos(self.carNode.zRotation) * MOVE_FORCE * moveDir
        
        let force = CGVector(dx: directionX, dy: directionY)
        self.carNode.physicsBody?.applyImpulse(force)
       
    }
    
    
}
