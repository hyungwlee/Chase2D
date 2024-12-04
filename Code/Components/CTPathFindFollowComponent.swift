//
//  CTPathFindFollowComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/3/24.
//

import GameplayKit
import SpriteKit

class CTPathFindFollowComponent: GKComponent {
    let target: CGPoint
    let followingNode: SKSpriteNode
    
    init(followingNode: SKSpriteNode, target: CGPoint) {
        self.target = target
        self.followingNode = followingNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
    
    func applyDeath(){
        
    }

    // TODO: set appearance accodring to health
    
}
