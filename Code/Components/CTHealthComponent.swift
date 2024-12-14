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
    weak var gameScene: CTGameScene?
    
    init(carNode: SKSpriteNode) {
        self.car = carNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
    
    func applyDeath(){
        
        // have a more drastic death effect later
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let scale = SKAction.scale(by: 1.3, duration: 0.1)
        
        self.car.run(scale)
        self.car.run(fadeOut){
            self.explode()
            self.car.removeFromParent()
        }
    }
    func explode() {
        guard let gameScene else { return }
        if let explosion = SKEmitterNode(fileNamed: "CTCarExplosion") {
            explosion.position = car.position
            explosion.particleSize = CGSize(width: 100.0, height: 100.0)
            gameScene.addChild(explosion)

            // Remove the emitter after 3 seconds
            let wait = SKAction.wait(forDuration: 3.0)
            let reduce_emmission = SKAction.run {
                explosion.particleBirthRate = 0
            }
            let wait2 = SKAction.wait(forDuration: 1.0)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, reduce_emmission, wait2, remove]))
        }
    }

    // TODO: set appearance accodring to health
    
}
