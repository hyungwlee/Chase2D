import SpriteKit

class CTCarNode: SKSpriteNode {
    
    let STEER_IMPULSE = 0.05
    let MOVE_FORCE:CGFloat = 1200
    let DRIFT_FORCE:CGFloat = 1000
    let DRIFT_VELOCITY_THRESHOLD: CGFloat = 25;
    
    enum driveDir {
        case forward
        case backward
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        texture?.filteringMode = .nearest
        enablePhysics()
    }
    
    func enablePhysics(){
        if(physicsBody == nil){
            physicsBody = SKPhysicsBody(rectangleOf: self.size)
        }
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 50 // Adjust for realistic movement
        physicsBody?.friction = 10
        physicsBody?.restitution = 1 // Controls bounciness
        physicsBody?.angularDamping = 24 // Dampen rotational movement
        physicsBody?.linearDamping = 10 // Dampen forward movement slightly
    }
    
    func steer(moveDirection: CGFloat){
        self.physicsBody?.applyAngularImpulse(moveDirection * STEER_IMPULSE * -1.0);
       
        // drift
        guard let angularVelocity = self.physicsBody?.angularVelocity else { return }
        let driftFactor = tanh(pow(angularVelocity, 2) / (DRIFT_VELOCITY_THRESHOLD))
        
        let directionX = cos(self.zRotation) * DRIFT_FORCE * moveDirection * -1 * driftFactor // -1 to flip direction from moveDirection
        let directionY = sin(self.zRotation) * DRIFT_FORCE * moveDirection * -1 * driftFactor;
        let force = CGVector(dx: directionX, dy: directionY)
        physicsBody?.applyImpulse(force)
       
    }
    
    func drive(driveDir: driveDir){
        
        var moveDir = 0.0
        switch driveDir {
        case .forward:
            moveDir = 1.0
            break
        case .backward:
            moveDir = -1.0
            break
        }
       
        let directionX = -sin(self.zRotation) * MOVE_FORCE * moveDir
        let directionY = cos(self.zRotation) * MOVE_FORCE * moveDir
        
        let force = CGVector(dx: directionX, dy: directionY)
        physicsBody?.applyImpulse(force)
        
    }
}
