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
    weak var gameScene: CTGameScene?
    
    init(carNode: CTCarNode) {
        self.carNode = carNode
        super.init()
    }
    
    func prepareComponents () {
        
        guard let gameScene else { return }
        
        let drivingComponent = CTDrivingComponent(carNode: carNode, enableSmoke: true)
        drivingComponent.MOVE_FORCE = gameInfo?.playerSpeed ?? 1300
        
        for driftParticle in drivingComponent.driftParticles {
            driftParticle.targetNode = gameScene
        }
        drivingComponent.smokeParticle?.targetNode = gameScene
        
        let steeringComponent = CTSteeringComponent(carNode: carNode)
        steeringComponent.STEER_IMPULSE = 0.06
        
        let fuelArrow = CTPickupFollowArrow(carNode: carNode)
            
        addComponent(drivingComponent)
        addComponent(steeringComponent)
        addComponent(fuelArrow)
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
