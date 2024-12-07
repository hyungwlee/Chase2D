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
    var layoutInfo: CTLayoutInfo = .init(screenSize: .zero)
    
    private(set) var stateMachine: GKStateMachine?
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameMode = gameMode
        super.init(dependencies: dependencies)
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
        if let drivingComponent = gameScene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: .forward)
        }
        
        gameScene.destroyCops()
        // change cop car speed
        gameScene.copEntities = []
        
    }
}



