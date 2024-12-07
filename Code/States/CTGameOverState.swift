//
//  CTGameOverState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/3/24.
//

import GameplayKit

class CTGameOverState: GKState {
    
    let context: CTGameContext
    let scene: CTGameScene
    
    var gamePlayState: CTGamePlayState?
    var restartPressed = false
    
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
        gamePlayState = previousState as? CTGamePlayState
        
        scene.gameInfo.restart.isHidden = false
        restartPressed = false

//        print("entered game over state")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        gamePlayState?.handleCameraMovement()
        
        if (scene.gameInfo.restart.tapped && !restartPressed)
        {
            resetGame()
        }
    }
    
    func handlePlayerDeath(){
        
        scene.gameInfo.setGameOver()
        
        if let drivingComponent = scene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .none)
        }
        // change cop car speed
        for copCar in scene.copCarEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.00001
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.00001
            }
        }
        for copCar in scene.copTruckEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.0001
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.00001
            }
        }
        for copCar in scene.copTankEntities {
            if let drivingComponent = copCar.component(ofType: CTDrivingComponent.self) {
                drivingComponent.MOVE_FORCE = 0.0001
            }
            if let steeringComponent = copCar.component(ofType: CTSteeringComponent.self) {
                steeringComponent.STEER_IMPULSE = 0.00001
            }
        }
    }
    
    
    func resetGame() {
        restartPressed = true
        
        var gameInfo = scene.gameInfo
        
        scene.playerCarEntity?.carNode.position = CGPoint(x: 0.0, y: 0.0)
        if let drivingComponent = scene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .forward)
        }
        // change cop car speed
        scene.copEntities = []
        scene.copCarEntities = []
        scene.copTankEntities = []
        scene.copTruckEntities = []
        
        
        gameInfo.gameOver = false
        gameInfo.playerSpeed = 810
        
        gameInfo.copCarSpeed = 810
        gameInfo.copSpeed = 20
        
        
        gameInfo.numberOfCops = 0
        
        gameInfo.MAX_NUMBER_OF_COPS = 5
        gameInfo.MAX_NUMBER_OF_PEDS = 10
        
        gameInfo.currentWave = 0
        
        gameInfo.canSpawnPoliceTrucks = false
        gameInfo.canSpawnTanks = false
        gameInfo.gunShootInterval = 700_000_000
        
        // cash
        gameInfo.powerUpPeriod = 2
        gameInfo.cashCollected = 0
        gameInfo.isFuelPickedUp = true
        gameInfo.isCashPickedUp = true
        gameInfo.fuelPosition = CGPoint(x: 0.0, y: 0.0)
        
        
        gameInfo.fuelLevel = 100.0
        
        gameInfo.score = 0
        gameInfo.scoreChangeFrequency = 1.0
        
        gameInfo.bulletShootInterval = 1
        
        context.stateMachine?.enter(CTGamePlayState.self)
        //TODO: need to make a lot of function calls
    }
    
}
