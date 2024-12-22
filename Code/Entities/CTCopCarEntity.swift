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
            
        let drivingComponent = CTDrivingComponent(carNode: carNode, enableSmoke: true)
        drivingComponent.MOVE_FORCE = gameInfo?.copCarSpeed ?? 100
        for driftParticle in drivingComponent.driftParticles {
            driftParticle.targetNode = gameScene
        }
        drivingComponent.smokeParticle?.targetNode = gameScene
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.05
        steeringComponent.DRIFT_FORCE = 0.05
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 6
        
        let healthComponent = CTHealthComponent(carNode: carNode)
        healthComponent.gameScene = gameScene
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
        addComponent(healthComponent)
        addComponent(CTArrestingCopComponent(carNode: carNode, entity: self))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
