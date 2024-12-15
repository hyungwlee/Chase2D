//
//  CTCopEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/3/24.
//

import GameplayKit
import SpriteKit

class CTCopEntity: GKEntity {
    let cop: DriveableNode
    var gameInfo: CTGameInfo?
    
    init(cop: DriveableNode) {
        self.cop = cop
        super.init()
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: cop, enableSmoke: true)
        drivingComponent.MOVE_FORCE = gameInfo?.copSpeed ?? 100
        drivingComponent.driftParticles = []
        
        let steeringComponent = CTSteeringComponent(carNode: cop)
        steeringComponent.STEER_IMPULSE = 0.0005
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTCopWalkingComponent(cop: cop))
        addComponent(CTHealthComponent(carNode: cop))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
