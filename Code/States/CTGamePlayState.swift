//
//  CTGameIdelState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import GameplayKit

class CTGamePlayState: GKState {
    weak var scene: CTGameScene?
    weak var context: CTGameContext?
    var moveDirection: CGFloat = 0.0
    var isTouchingSingle: Bool = false
    var isTouchingDouble: Bool = false
    var touchLocations: Array<CGPoint> = []
    var driveDir = CTDrivingComponent.driveDir.forward
    
    var startTime = 0.0
    var initialTimeSet = false
    
    var firstWaveSet = false
    var secondWaveSet = false
    var thirdWaveSet = false
    var fourthWaveSet = false
    
    var scaleEffectSet = false
    var time = 0.0
    
    init(scene: CTGameScene, context: CTGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter idle state")
        
        scene?.gameInfo.setIsPaused(val: false)
   }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let scene else { return }
        
        time = seconds
        if !initialTimeSet {
            startTime = seconds
            initialTimeSet = true
        }
        
        let elapsedTime = seconds - startTime
        setGameWaveModeParams(elapsedTime: elapsedTime)
//        print(scene.gameInfo.playerSpeed)
//        print(scene.gameInfo.copSpeed)
//        print(scene.gameInfo.MAX_NUMBER_OF_COPS)
//        print(scene.gameInfo.canSpawnPoliceTrucks)
//        print(scene.gameInfo.canSpawnTanks)
       
        handleCameraMovement()
        
        if(self.touchLocations != []){
            if(isTouchingDouble){
                
            }
            else if(isTouchingSingle){
                self.moveDirection = self.touchLocations[0].x < scene.frame.midX ? -1.0 : 1.0
            }
        }
         // components
        
        if let drivingComponent = scene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: self.driveDir)
        }
        
        if let steerComponent = scene.playerCarEntity?.component(ofType: CTSteeringComponent.self){
            steerComponent.steer(moveDirection: self.moveDirection)
        }
        
    }
    
    
    func setGameWaveModeParams(elapsedTime: CGFloat){
        guard let scene else { return }
        
        if(elapsedTime > scene.gameInfo.FIRST_WAVE_TIME && elapsedTime < scene.gameInfo.FIRST_WAVE_TIME + 1 && !firstWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 5
            scene.gameInfo.playerSpeed += 50
            scene.gameInfo.copSpeed += 50
            scene.gameInfo.currentWave += 1
            firstWaveSet = true
            print("firstWaveOver")
        }
        if(elapsedTime > scene.gameInfo.SECOND_WAVE_TIME && elapsedTime < scene.gameInfo.SECOND_WAVE_TIME + 1 && !secondWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 5
            scene.gameInfo.playerSpeed += 150
            scene.gameInfo.copSpeed += 150
            scene.gameInfo.canSpawnPoliceTrucks = true
            scene.gameInfo.currentWave += 1
            secondWaveSet = true
            print("secondWaveOver")
        }
        if(elapsedTime > scene.gameInfo.THIRD_WAVE_TIME && elapsedTime < scene.gameInfo.THIRD_WAVE_TIME + 1 && !thirdWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 3
            scene.gameInfo.playerSpeed += 100
            scene.gameInfo.copSpeed += 100
            scene.gameInfo.canSpawnTanks = true
            scene.gameInfo.currentWave += 1
            thirdWaveSet = true
            print("thirdwaveover")
        }
        if(elapsedTime > scene.gameInfo.FOURTH_WAVE_TIME && elapsedTime < scene.gameInfo.FOURTH_WAVE_TIME + 1 && !fourthWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 2
            scene.gameInfo.playerSpeed += 100
            scene.gameInfo.copSpeed += 100
            scene.gameInfo.currentWave += 1
            fourthWaveSet = true
            print("fourthWaveOver")
        }
    }
       
    func handleTouchStart(_ touches: Set<UITouch>) {
        guard let scene, let context else { return }
        isTouchingSingle = false
        isTouchingDouble = false
         
        let loc = touches.first?.location(in: scene.view)
        
        
        // this code is for emulator only
        if(loc?.y ?? 0.0 > (scene.frame.height - 100)){
            isTouchingDouble = true
            self.driveDir = CTDrivingComponent.driveDir.backward
            self.moveDirection = -1.0
            for touch in touches{
                self.touchLocations.append(touch.location(in: scene.view))
                return
            }
        }else if(touches.count == 1){
            isTouchingSingle = true
            self.driveDir = CTDrivingComponent.driveDir.forward
            self.touchLocations.append((touches.first?.location(in: scene.view))!)
        }
        
//        if(touches.count > 1){
//            isTouchingDouble = true
//            for touch in touches{
//                self.touchLocations?.append(touch.location(in: scene.view))
//            }
//        }else if(touches.count == 1){
//            isTouchingSingle = true
//            self.touchLocations?.append((touches.first?.location(in: scene.view))!)
//        }
    }
    
    func handleTouchEnded(_ touch: UITouch) {
        isTouchingSingle = false
        isTouchingDouble = false
        self.touchLocations = []
        self.moveDirection = 0
        self.driveDir = CTDrivingComponent.driveDir.forward
    }
    
    func handleCameraMovement() {
            
        let randomNumber = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 5).nextInt())
        let randomOffsetX = sin(time * 2) * (10 + randomNumber)
        let randomOffsetY = cos(time * 2) * (10 + randomNumber)
        
        let targetPosition = CGPoint(x: (scene?.playerCarEntity?.carNode.position.x ?? 0.0) + randomOffsetX,  y: (scene?.playerCarEntity?.carNode.position.y ?? 0.0) + randomOffsetY)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.25)
        
        if self.scene?.playerSpeed ?? 101 < 70 {
            let scaleAction = SKAction.scale(to: 0.2, duration: 0.2)
            scene?.cameraNode?.run(scaleAction)
        } else {
            let scaleAction = SKAction.scale(to: 0.35, duration: 0.2)
            scene?.cameraNode?.run(scaleAction)
        }
        scene?.cameraNode?.run(moveAction)
    }
    
}
