//
//  CTShootingComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/26/24.
//

import GameplayKit
import SpriteKit

class CTShootingComponent: GKComponent {
    let car: SKSpriteNode
    var reloading = false
    
    init(carNode: SKSpriteNode) {
        self.car = carNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
    
    func shoot(target: CGPoint) {
        
        if reloading { return }
        
        let bullet = CTBulletNode(imageNamed: "damageBoost", size: CGSize(width: 2.0, height: 2.0))
        bullet.position = car.position
        
        let dVector = CGVector(
            dx: target.x - car.position.x,
            dy: target.y - car.position.y
        )
        
        let dVectorMagnitude = sqrt(dVector.dx * dVector.dx + dVector.dy * dVector.dy)
        let direction = CGVector(dx: dVector.dx/dVectorMagnitude, dy: dVector.dy / dVectorMagnitude)
        
        car.scene?.addChild(bullet)
       
        if let physicsBody = bullet.physicsBody {
         physicsBody.applyImpulse(CGVector(
            dx: direction.dx * 40 + physicsBody.velocity.dx,
            dy: direction.dy * 40 + physicsBody.velocity.dy
        ))
        }
       
        
        bullet.run(SKAction.sequence([
            SKAction.wait(forDuration: 5),
            SKAction.removeFromParent()
        ]))
            
        reloading = true
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000 * 1)
            reloading = false
        }
        
    }
    
    
}
