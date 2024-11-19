//
//  CTCopCarEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit

class CTCopCarEntity: GKEntity {
    let carNode: CTCopNode
    var gameInfo: CTGameInfo?
    
    init(carNode: CTCopNode) {
        self.carNode = carNode
        super.init()
       
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        drivingComponent.MOVE_FORCE = gameInfo?.copSpeed ?? 1300
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.05
        steeringComponent.DRIFT_FORCE = 0.05
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
