//
//  SteeringComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit

class CTSteeringComponent: GKComponent {
    
    let carNode: SKSpriteNode
    var STEER_IMPULSE = 0.05
    var DRIFT_FORCE:CGFloat = 1000
    var DRIFT_VELOCITY_THRESHOLD: CGFloat = 6
    
    init(carNode: SKSpriteNode) {
        self.carNode = carNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    func steer(moveDirection: CGFloat){
        
        // rotate
        let angularVelocity = self.carNode.physicsBody?.angularVelocity ?? 0.0
        let driftFactor = tanh(abs(angularVelocity) / (DRIFT_VELOCITY_THRESHOLD))
        self.carNode.physicsBody?.applyAngularImpulse(moveDirection * STEER_IMPULSE * -1.0 + STEER_IMPULSE * driftFactor * moveDirection * -1.0);
        
        // drift
        let directionX = cos(self.carNode.zRotation) * DRIFT_FORCE * moveDirection * -1 * driftFactor // -1 to flip direction from moveDirection
        let directionY = sin(self.carNode.zRotation) * DRIFT_FORCE * moveDirection * -1 * driftFactor;
        let force = CGVector(dx: directionX, dy: directionY)
        self.carNode.physicsBody?.applyImpulse(force)
       
    }
    
}
