import SpriteKit

class CTCarNode: SKSpriteNode{
    
    let STEER_IMPULSE = 0.05
    let MOVE_FORCE:CGFloat = 1200
    let DRIFT_FORCE:CGFloat = 800
    let DRIFT_VELOCITY_THRESHOLD: CGFloat = 6
    
    var health = 100.0
    
    enum driveDir {
        case forward
        case backward
        case none
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
        physicsBody?.friction = 0
        physicsBody?.restitution = 1 // Controls bounciness
        physicsBody?.angularDamping = 24 // Dampen rotational movement
        physicsBody?.linearDamping = 10 // Dampen forward movement slightly
        physicsBody?.categoryBitMask = CTPhysicsCategory.car
        physicsBody?.collisionBitMask = CTPhysicsCategory.building
        physicsBody?.contactTestBitMask = CTPhysicsCategory.building
    }
    
    func steer(moveDirection: CGFloat){
        
        // drift
        let angularVelocity = self.physicsBody?.angularVelocity ?? 0.0
        let driftFactor = tanh(abs(angularVelocity) / (DRIFT_VELOCITY_THRESHOLD))
        
        self.physicsBody?.applyAngularImpulse(moveDirection * STEER_IMPULSE * -1.0 + STEER_IMPULSE * driftFactor * moveDirection * -1.0);
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
        case .none:
            moveDir = 0.0
        }
       
        let directionX = -sin(self.zRotation) * MOVE_FORCE * moveDir
        let directionY = cos(self.zRotation) * MOVE_FORCE * moveDir
        
        let force = CGVector(dx: directionX, dy: directionY)
        physicsBody?.applyImpulse(force)
       
    }
}
