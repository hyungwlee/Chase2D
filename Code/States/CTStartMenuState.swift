//
//  CTStartMenuState.swift
//  Chase2D
//
//  Created by James Calder on 11/30/24.
//

import GameplayKit

class CTStartMenuState: GKState {
    
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
        print("entered start menu state")
        scene?.gameInfo.gameOver = false
        
        if let drivingComponent = scene?.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .none)
        }
        // change cop car speed
        for copCar in scene!.copCarEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE / 10000000
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = steeringComponent.STEER_IMPULSE / 10000000
            }
        }
        for copCar in scene!.copTruckEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE / 10000000
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = steeringComponent.STEER_IMPULSE / 10000000
            }
        }
        for copCar in scene!.copTankEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE / 10000000
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = steeringComponent.STEER_IMPULSE / 10000000
            }
        }
    }
    
    func handleTouchStart(_ touches: Set<UITouch>) {
        guard let scene, let context else { return }
        let gameInfo = scene.gameInfo
        
        // Tap to play logic
            
            if let drivingComponent = scene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
                drivingComponent.drive(driveDir: .forward)
            }
            // change cop car speed
            for copCar in scene.copCarEntities {
                if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                    drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE * 10000000
                }
                if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                    steeringComponent.STEER_IMPULSE = steeringComponent.STEER_IMPULSE / 10000000
                }
            }
            for copCar in scene.copTruckEntities {
                if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                    drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE * 10000000
                }
                if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                    steeringComponent.STEER_IMPULSE = steeringComponent.STEER_IMPULSE / 10000000
                }
            }
            for copCar in scene.copTankEntities {
                if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                    drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE * 10000000
                }
                if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                    steeringComponent.STEER_IMPULSE = steeringComponent.STEER_IMPULSE * 10000000
                }
            }
            
            context.stateMachine?.enter(CTGamePlayState.self)
        
        
        scene.pedCarSpawner?.populateAI()
        scene.copCarSpawner?.populateAI()
    }
    
    func handleTouchEnd(_ touch: UITouch){
        
    }
    
}
