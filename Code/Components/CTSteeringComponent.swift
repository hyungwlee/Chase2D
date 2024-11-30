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
        
        // drift
        let velocity = self.carNode.physicsBody?.velocity ?? CGVector(dx: 0.0, dy: 0.0)
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy + velocity.dy)

        let forwardVector = CGVector(dx: -sin(self.carNode.zRotation), dy: cos(self.carNode.zRotation))
        
        let lateralVelocity = CGVector(
            dx: -forwardVector.dy * (forwardVector.dy * velocity.dx + forwardVector.dx * velocity.dy),
            dy: forwardVector.dx * (forwardVector.dy * velocity.dx + forwardVector.dx * velocity.dy)
        )
        
        // Drift angle: Angle between velocity and forward direction
        let driftAngle = atan2(velocity.dy, velocity.dx) - self.carNode.zRotation

        // Normalize drift angle to the range [-π, π]
        let normalizedDriftAngle = atan2(sin(driftAngle), cos(driftAngle))

        // Calculate grip multiplier based on the drift angle
        let maxDriftAngle: CGFloat = .pi / 2 // 90° is the max drift angle for full sliding
        let gripMultiplier = max(0.1, 1.0 - abs(normalizedDriftAngle) / maxDriftAngle)
        
        self.carNode.physicsBody?.applyImpulse(
            CGVector(dx: -lateralVelocity.dx * 1/gripMultiplier * 0.01, dy: -lateralVelocity.dy * 1/gripMultiplier * 0.01))
        
        // turn
        let torque = moveDirection * STEER_IMPULSE * -1.0 * 10 * 1/gripMultiplier * min(max(speed, 0),1)
        print(gripMultiplier)
        self.carNode.physicsBody?.applyTorque(torque);
       
    }
    
}
