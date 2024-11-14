//
//  CarEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit

class CTPlayerCarEntity: GKEntity {
    let carNode: CTCarNode
    var gameInfo: CTGameInfo?
    
    init(carNode: CTCarNode) {
        self.carNode = carNode
        super.init()
    }
    
    func prepareComponents () {
        
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        drivingComponent.MOVE_FORCE = gameInfo?.playerSpeed ?? 1300
        print(gameInfo?.playerSpeed)
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.04
        steeringComponent.DRIFT_FORCE = 0.04
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 6
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
