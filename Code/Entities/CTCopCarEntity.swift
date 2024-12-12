//
//  CTCopCarEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit

class CTCopCarEntity: GKEntity {
    let carNode: CTCopCarNode
    var gameInfo: CTGameInfo?
    weak var gameScene: CTGameScene?
    
    init(carNode: CTCopCarNode) {
        self.carNode = carNode
        super.init()
       
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        drivingComponent.MOVE_FORCE = gameInfo?.copCarSpeed ?? 100
        for driftParticle in drivingComponent.driftParticles {
            driftParticle.targetNode = gameScene
        }
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.05
        steeringComponent.DRIFT_FORCE = 0.05
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 6
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
        addComponent(CTHealthComponent(carNode: carNode))
        addComponent(CTArrestingCopComponent(carNode: carNode))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
