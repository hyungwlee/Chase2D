//
//  CTHealthComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/28/24.
//

import GameplayKit
import SpriteKit

class CTHealthComponent: GKComponent {
    let car: SKSpriteNode
    
    init(carNode: SKSpriteNode) {
        self.car = carNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
    
    func applyDeath(){
        
        // have a more drastic death effect later
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scale = SKAction.scale(by: 1.5, duration: 0.3)
        
        self.car.run(scale)
        self.car.run(fadeOut){
            self.car.removeFromParent()
        }
    }

    // TODO: set appearance accodring to health
    
}
