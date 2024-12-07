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
        
        scene?.gameInfo.setIsPaused(val: true)
        
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
    
    func handleTouchStart(_ touches: Set<UITouch>) {
        guard let scene, let context else { return }
        var gameInfo = scene.gameInfo
        
        // Tap to play logic
        if ((gameInfo.instructionsLabel.isHidden == false) && (gameInfo.isPaused == true)){
            context.stateMachine?.enter(CTGamePlayState.self)
        }
        
        scene.pedCarSpawner?.populateAI()
        scene.copCarSpawner?.populateAI()
    }
    
    func handleTouchEnd(_ touch: UITouch){
        
    }
    
}
