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
    var STEER_IMPULSE = 0.04
    var DRIFT_FORCE:CGFloat = 0.04
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
        self.carNode.physicsBody?.applyAngularImpulse(moveDirection * STEER_IMPULSE * -1.0 + DRIFT_FORCE * driftFactor * moveDirection * -1.0);
        
        // drift
        let directionX1 = cos(self.carNode.zRotation) * DRIFT_FORCE * moveDirection * -1 * driftFactor * 20000 // -1 to flip direction from moveDirection
        let directionY1 = sin(self.carNode.zRotation) * DRIFT_FORCE * moveDirection * -1 * driftFactor * 20000;
        
        // the speed decreases while drifting
        let directionX2 = -sin(self.carNode.zRotation) * (carNode.entity?.component(ofType: CTDrivingComponent.self)?.MOVE_FORCE ?? 1300) * -0.4 * driftFactor
        let directionY2 = cos(self.carNode.zRotation) * (carNode.entity?.component(ofType: CTDrivingComponent.self)?.MOVE_FORCE ?? 1300) * -0.4 * driftFactor
        
        let force = CGVector(dx: directionX1 + directionX2, dy: directionY1 + directionY2)
        self.carNode.physicsBody?.applyImpulse(force)
       
    }
    
}
