//
//  CTCopEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/3/24.
//

import GameplayKit
import SpriteKit

class CTCopEntity: GKEntity {
    let carNode: CTCopCarNode
    var gameInfo: CTGameInfo?
    
    init(carNode: CTCopCarNode) {
        self.carNode = carNode
        super.init()
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        drivingComponent.MOVE_FORCE = gameInfo?.copSpeed ?? 100
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.05
        steeringComponent.DRIFT_FORCE = 0.05
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 6
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
        addComponent(CTHealthComponent(carNode: carNode))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
