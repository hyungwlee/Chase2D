//
//  CTGameIdleState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/12/24.
//

import GameplayKit

class CTGameIdleState: GKState {
    
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
    
    override func didEnter(from previousState: GKState?)
    {
        print("game entered pause state")
        
        scene?.gameInfo.setIsPaused(val: true)
        
        //TODO: I want the camera to zoom out on the start screen so the player can see the map better
//        let scaleAction = SKAction.scale(to: 100, duration: 0.0)
//        scene?.cameraNode?.run(scaleAction)
        
        if let drivingComponent = scene?.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .none)
        }
        // change cop car speed
        for copCar in scene!.copCarEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.00001
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.00001
            }
        }
        for copCar in scene!.copTruckEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.0001
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.00001
            }
        }
        for copCar in scene!.copTankEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.0001
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.00001
            }
        }
    }
    
}
