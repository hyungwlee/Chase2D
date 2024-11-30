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
    var interval = 1_000_000_000
    
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
         physicsBody.velocity = CGVector(
            dx: direction.dx * 300,
            dy: direction.dy * 300
        )
        }
       
        // incase the bullet doesn't hit anything we remove it from the scene after 5 seconds
        
        let initialContactTestBitMask = bullet.physicsBody?.contactTestBitMask ?? CTPhysicsCategory.none
       
        let wait = SKAction.wait(forDuration: 0.01)
        let run = SKAction.run {
            bullet.physicsBody?.contactTestBitMask = CTPhysicsCategory.none
        }
        let reset = SKAction.run{
            bullet.physicsBody?.contactTestBitMask = initialContactTestBitMask
        }
        let wait2 = SKAction.wait(forDuration: 5)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([run, wait, reset, wait2, remove])
        
        bullet.run(sequence)
        
        reloading = true
        Task {
            try? await Task.sleep(nanoseconds: UInt64(interval))
            reloading = false
        }
        
    }
    
    
}
