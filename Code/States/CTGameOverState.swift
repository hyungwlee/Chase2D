//
//  CTGameOverState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/3/24.
//

import GameplayKit

class CTGameOverState: GKState {
    
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
    
    override func didEnter(from previousState: GKState?) {
        print("did enter game over state")
        handlePlayerDeath()
    }
    
    func handlePlayerDeath(){
        print("You died!")
        scene?.playerCarNode?.drive(driveDir: .none)
        scene!.gameInfo.setGameOver()
        // change cop car speed
        for cop in scene!.copCars {
            cop.MOVE_FORCE = 50
            cop.STEER_IMPULSE = 0.001
        }
    }
    
}
