//
//  CTGameOverState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/3/24.
//

import GameplayKit

class CTGameOverState: GKState {
    
    weak var context: CTGameContext?
    weak var scene: CTGameScene?
    
    init(scene: CTGameScene, context: CTGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        handlePlayerDeath()
    }
    
    func handlePlayerDeath(){
        
//        scene!.gameInfo.setGameOver()
        
        if let drivingComponent = scene?.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .none)
        }
        // change cop car speed
        for copCar in scene!.copCarEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.05
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.01
            }
        }
    }
    
}
