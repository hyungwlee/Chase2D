//
//  CTGameOverState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/3/24.
//

import GameplayKit
import AVFAudio

class CTGameOverState: GKState {
    
    let context: CTGameContext
    let scene: CTGameScene
    
    var gameOverSound: AVAudioPlayer?
    
    var gamePlayState: CTGamePlayState?
    
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
        
        scene.gameInfo.restartButton.isHidden = false
        scene.gameInfo.restartButton.tapped = false
        
        scene.bgMusicPlayer?.stop()
        if let gameOverURL = Bundle.main.url(forResource: "gameOver", withExtension: "mp3") {
            do {
                gameOverSound = try AVAudioPlayer(contentsOf: gameOverURL)
                gameOverSound?.volume = 0.4
                gameOverSound?.play()
            } catch {
                print("Error loading gameOver sound: \(error)")
            }
        }
        
        scene.speed = 0.01

    }
    
    override func update(deltaTime seconds: TimeInterval) {
        gamePlayState?.handleCameraMovement()
        
        if (scene.gameInfo.restartButton.tapped)
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
        scene.speed = 1
        context.restartGame()
        context.stateMachine?.enter(CTGamePlayState.self)
    }
    
}
