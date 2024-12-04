//
//  CTCopTankEntity.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/28/24.
//
import GameplayKit
import SpriteKit

class CTCopTankEntity: GKEntity {
    let carNode: CTCopTankNode
    var gameInfo: CTGameInfo?
    
    init(carNode: CTCopTankNode) {
        self.carNode = carNode
        super.init()
       
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        drivingComponent.MOVE_FORCE = (gameInfo?.copCarSpeed ?? 100) * 3
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 2.5
        steeringComponent.DRIFT_FORCE = 0.4
        
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 10
        
        let shootingComponent = CTShootingComponent(carNode: carNode)
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
        addComponent(shootingComponent)
        addComponent(CTHealthComponent(carNode: carNode))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
