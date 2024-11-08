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
//        checkPointsList = [player.position ?? CGPoint(x: 0, y: 0)]
         
        currentTarget = player?.position ?? CGPoint(x: 0, y: 0)
        
        follow(target: currentTarget)
    }
}
