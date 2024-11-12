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
    
    init(carNode: CTCarNode) {
        self.carNode = carNode
        super.init()
        
        
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.05
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
