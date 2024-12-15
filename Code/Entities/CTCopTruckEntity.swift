//
//  CTCopTruckEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/28/24.
//
import GameplayKit
import SpriteKit

class CTCopTruckEntity: GKEntity {
    let carNode: CTCopTruckNode
    var gameInfo: CTGameInfo?
    weak var gameScene: CTGameScene?
    
    init(carNode: CTCopTruckNode) {
        self.carNode = carNode
        super.init()
       
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: carNode, enableSmoke: true)
        drivingComponent.MOVE_FORCE = (gameInfo?.copCarSpeed ?? 100) * 1.5
        for driftParticle in drivingComponent.driftParticles {
            driftParticle.targetNode = gameScene
        }
        drivingComponent.smokeParticle?.targetNode = gameScene
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.1
        steeringComponent.DRIFT_FORCE = 0.1
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 8
        
        let healthComponent = CTHealthComponent(carNode: carNode)
        healthComponent.gameScene = gameScene
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
        addComponent(healthComponent)
        addComponent(CTArrestingCopComponent(carNode: carNode))
         
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
