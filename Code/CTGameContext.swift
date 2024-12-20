//  CTGameContext.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/26/24.
//

import Combine
import GameplayKit

class CTGameContext: GameContext{
    var gameScene: CTGameScene? {
        scene as? CTGameScene
    }
    let gameMode: GameModeType
    var gameInfo: CTGameInfo
    var layoutInfo: CTLayoutInfo
    
    private(set) var stateMachine: GKStateMachine?
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameMode = gameMode
        self.gameInfo = CTGameInfo()
        self.layoutInfo = CTLayoutInfo(screenSize: UIScreen.main.bounds.size)
        super.init(dependencies: dependencies)
        
        // Load the scene from the .sks file
        if let scene = SKScene(fileNamed: "CTGameScene") as? CTGameScene {
            scene.setContext(self) // Set the context
            scene.size = UIScreen.main.bounds.size
            self.scene = scene
        } else {
            fatalError("Failed to load CTGameScene from CTGameScene.sks")
        }
        
        configureStates()
        stateMachine?.enter(CTStartMenuState.self)
    }
        
    func updateLayoutInfo(withScreenSize size: CGSize){
        layoutInfo = CTLayoutInfo(screenSize: size)
    }
    
    func configureStates() {
        guard let gameScene else { return }
        print("did configure states")
        stateMachine = GKStateMachine(states: [
            CTStartMenuState(scene: gameScene, context: self),
            CTGamePlayState(scene: gameScene, context: self),
            CTGameIdleState(scene: gameScene, context: self),
            CTGameOverState(scene: gameScene, context: self)
        ])
    }
    
    func restartGame() {
        guard let gameScene else { return }
        
        gameScene.gameInfo.reset()
        
        gameScene.playerCarEntity?.carNode.position = CGPoint(x: 0.0, y: 0.0)
        gameScene.playerCarEntity?.carNode.zRotation = 0.0
        if let drivingComponent = gameScene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .forward)
        }
        
        if let fuelCan = gameScene.childNode(withName: "fuel") {
            fuelCan.removeFromParent()
        }
        if let cashNode = gameScene.childNode(withName: "cash") {
            cashNode.removeFromParent()
        }
        
        gameScene.destroyCops(gameRestart: true)
        gameScene.disableAllPowerup()
        
    }
    
//    func play()
//    {
//        context.stateMachine?.enter(CTGamePlayState.self)
//    }
//    func pause()
//    {
//        context.stateMachine?.enter(CTGameIdleState.self)
//    }
}



