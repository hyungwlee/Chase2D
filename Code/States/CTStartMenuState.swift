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
    var time = 0.0
    
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
//        scene?.gameInfo.gameOver = false
        
        
        if let drivingComponent = scene?.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .none)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        time = seconds
        handleCameraMovement()
    }
    
    func handleTouchStart(_ touches: Set<UITouch>) {
        guard let scene, let context else { return }
        let gameInfo = scene.gameInfo
        
        // Tap to play logic
            
            if let drivingComponent = scene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
                drivingComponent.drive(driveDir: .forward)
            }
            
            context.stateMachine?.enter(CTGamePlayState.self)
    }
    
    func handleTouchEnd(_ touch: UITouch){
        
    }
    
    func handleCameraMovement() {
            
        let randomNumber = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 5).nextInt())
        let randomOffsetX = sin(time * 2) * (10 + randomNumber)
        let randomOffsetY = cos(time * 2) * (10 + randomNumber)
//        let randomOffsetX = 0.0
//        let randomOffsetY = 0.0
        
        let targetPosition = CGPoint(x: (scene?.playerCarEntity?.carNode.position.x ?? 0.0) + randomOffsetX,  y: (scene?.playerCarEntity?.carNode.position.y ?? 0.0) + randomOffsetY)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.25)
        
        if self.scene?.playerSpeed ?? 101 < 70 {
            let scaleAction = SKAction.scale(to: 0.2, duration: 0.2)
            scene?.cameraNode?.run(scaleAction)
        } else {
            let scaleAction = SKAction.scale(to: 0.35, duration: 0.2)
//            let scaleAction = SKAction.scale(to: 1, duration: 0.2)
            scene?.cameraNode?.run(scaleAction)
        }
        
        scene?.cameraNode?.run(moveAction)
    }
    
}
