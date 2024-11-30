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
    
    init(carNode: CTCopTruckNode) {
        self.carNode = carNode
        super.init()
       
    }
    
    func prepareComponents(){
            
        let drivingComponent = CTDrivingComponent(carNode: carNode)
        drivingComponent.MOVE_FORCE = (gameInfo?.copSpeed ?? 100) * 1.5
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.1
        steeringComponent.DRIFT_FORCE = 0.1
        steeringComponent.DRIFT_VELOCITY_THRESHOLD = 8
        
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(CTSelfDrivingComponent(carNode: carNode))
        addComponent(CTHealthComponent(carNode: carNode))
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
