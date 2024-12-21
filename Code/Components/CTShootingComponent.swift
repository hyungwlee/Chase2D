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
        var bullet: SKSpriteNode
        let flameParticle = SKEmitterNode(fileNamed: "CTBulletFlame")
//        flameParticle?.position = CGPoint(x: 0.0, y: car.size.height / 2.0)
        flameParticle?.position = CGPoint(x: 0.0, y: 0.0)
        flameParticle?.particleSize = CGSize(width: 10, height: 10)
        
        if car.name == "player" {
            bullet = CTPlayerBulletNode(imageNamed: "CTdamageBoost", size: CGSize(width: 2.0, height: 2.0))
        } else {
            bullet = CTCopBulletNode(imageNamed: "CTdamageBoost", size: CGSize(width: 2.0, height: 2.0))
        }
        bullet.position = car.position
        
        let dVector = CGVector(
            dx: target.x - car.position.x,
            dy: target.y - car.position.y
        )
        
        let dVectorMagnitude = sqrt(dVector.dx * dVector.dx + dVector.dy * dVector.dy)
        let direction = CGVector(dx: dVector.dx/dVectorMagnitude, dy: dVector.dy / dVectorMagnitude)
        
        car.scene?.addChild(bullet)
        flameParticle?.targetNode = car.scene
        bullet.addChild(flameParticle!)
       
        if let physicsBody = bullet.physicsBody {
         physicsBody.velocity = CGVector(
            dx: direction.dx * 300,
            dy: direction.dy * 300
        )
        }
       
        // incase the bullet doesn't hit anything we remove it from the scene after 5 seconds
        
        
        let wait = SKAction.wait(forDuration: 5)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([wait, remove])
        
        bullet.run(sequence)
        
        reloading = true
        Task {
            try? await Task.sleep(nanoseconds: UInt64(interval))
            reloading = false
        }
        
    }
    
    
}
