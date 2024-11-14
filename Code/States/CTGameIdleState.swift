//
//  CTGameIdleState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/12/24.
//

import GameplayKit

class CTGameIdleState: GKState {
    
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
    }
    
}
