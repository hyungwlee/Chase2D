import SpriteKit

class CTCarNode: SKSpriteNode {
    
    let STEER_IMPULSE = 0.1
    let MOVE_FORCE:CGFloat = 1500
    let DRIFT_FORCE:CGFloat = 1000
    let DRIFT_VELOCITY_THRESHOLD: CGFloat = 25;
    
    init(){
        let texture = SKTexture(imageNamed: "Truck0")
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: texture.size())
        self.setScale(0.1)
        enablePhysics()
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemended")
    }
    
    func enablePhysics(){
        if(physicsBody == nil){
            physicsBody = SKPhysicsBody(rectangleOf: self.size)
            physicsBody?.isDynamic = true
            physicsBody?.affectedByGravity = false
            physicsBody?.mass = 50 // Adjust for realistic movement
            physicsBody?.friction = 10
            physicsBody?.restitution = 5 // Controls bounciness
            physicsBody?.angularDamping = 8 // Dampen rotational movement
            physicsBody?.linearDamping = 10 // Dampen forward movement slightly
        }
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
    
    func drive(){
        let directionX = -sin(self.zRotation) * MOVE_FORCE
        let directionY = cos(self.zRotation) * MOVE_FORCE
        
        let force = CGVector(dx: directionX, dy: directionY)
        physicsBody?.applyImpulse(force)
        
    }
}
