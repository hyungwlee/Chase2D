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
        drivingComponent.MOVE_FORCE = gameInfo?.copSpeed ?? 100
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.04
        steeringComponent.DRIFT_FORCE = 0.04
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 6
        
        let shootingComponent = CTShootingComponent(carNode: carNode)
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
//        addComponent(shootingComponent)
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
