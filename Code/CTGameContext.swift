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
    var layoutInfo: CTLayoutInfo
    
    private(set) var stateMachine: GKStateMachine?
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameMode = gameMode
        self.layoutInfo = CTLayoutInfo()
        super.init(dependencies: dependencies)
    }
        
    func configureLayoutInfo(withScreenSize size: CGSize){
        let screenSize = UIScreen.main.bounds.size
        let ssW = screenSize.width
        let ssH = screenSize.height
        layoutInfo = CTLayoutInfo()
        
        layoutInfo.playerCarSize = CGSize(width: ssW * 0.013, height: ssH * 0.015)
        layoutInfo.copCarSize = CGSize(width: ssW * 0.021, height: ssH * 0.017)
        layoutInfo.powerUpSize = CGSize(width: ssW * 0.012, height: ssW * 0.012)
    }
    
    func configureStates() {
        guard let gameScene else { return }
        print("did configure states")
        stateMachine = GKStateMachine(states: [
            CTGamePlayState(scene: gameScene, context: self),
            CTGameOverState(scene: gameScene, context: self),
        ])
    }
}



