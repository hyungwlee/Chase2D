//
//  SteeringComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit

class CTSteeringComponent: GKComponent {
    
    let carNode: DriveableNode
    var STEER_IMPULSE = 0.04
    var DRIFT_FORCE:CGFloat = 0.04
    var DRIFT_VELOCITY_THRESHOLD: CGFloat = 6
    
    init(carNode: DriveableNode) {
        self.carNode = carNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    func steer(moveDirection: CGFloat) {
        guard let physicsBody = self.carNode.physicsBody else { return }

        // Get current velocity and speed
        let velocity = physicsBody.velocity
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)

        // Calculate forward and lateral vectors
        let forwardVector = CGVector(dx: cos(carNode.zRotation), dy: sin(carNode.zRotation))
        let forwardVelocity = dotProduct(velocity, forwardVector)
        let lateralVelocity = CGVector(dx: velocity.dx - forwardVector.dx * forwardVelocity,
                                       dy: velocity.dy - forwardVector.dy * forwardVelocity)

        // Reduce lateral velocity to simulate tire grip
//        let reducedLateralVelocity = CGVector(dx: lateralVelocity.dx * 1, dy: lateralVelocity.dy * 1)
//        physicsBody.velocity = CGVector(dx: forwardVector.dx * forwardVelocity + reducedLateralVelocity.dx,
//                                         dy: forwardVector.dy * forwardVelocity + reducedLateralVelocity.dy)

        // Apply torque to simulate steering and drifting
        let torque = moveDirection * STEER_IMPULSE * -1.0 * 100 * min(max(speed, 0), 1)
        physicsBody.applyTorque(torque)
//
//        // Apply additional force to simulate drift
//        let driftForce = CGVector(dx: lateralVelocity.dx * -5, dy: lateralVelocity.dy * -5)
//        physicsBody.applyForce(driftForce)
    }

    // Helper: Dot product for velocity calculation
    func dotProduct(_ vector1: CGVector, _ vector2: CGVector) -> CGFloat {
        return vector1.dx * vector2.dx + vector1.dy * vector2.dy
    }
    
}
