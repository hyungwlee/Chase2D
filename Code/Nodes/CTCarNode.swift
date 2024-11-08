import SpriteKit

class CTCarNode: SKSpriteNode{
    
    var STEER_IMPULSE = 0.05
    var MOVE_FORCE:CGFloat = 1300
    var DRIFT_FORCE:CGFloat = 1000
    var DRIFT_VELOCITY_THRESHOLD: CGFloat = 6
    
    var health = 100.0
    
    enum driveDir {
        case forward
        case backward
        case none
    }
    
    init(imageNamed: String, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed )
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: size)
        enablePhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not implemented")
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
        physicsBody?.categoryBitMask = CTPhysicsCategory.collidableObstacle
        physicsBody?.collisionBitMask = CTPhysicsCategory.collidableObstacle
        physicsBody?.contactTestBitMask = CTPhysicsCategory.collidableObstacle
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
    
    func calculateAngle(pointA: CGPoint, pointB: CGPoint) -> CGFloat{
        let a1 = atan(pointA.y / pointA.x) < 0 ? .pi + atan(pointA.y / pointA.x) : atan(pointA.y / pointA.x)
        let a2 = atan(pointB.y / pointB.x) < 0 ? .pi + atan(pointB.y / pointB.x) : atan(pointB.y / pointB.x)
        
        return a2 - a1
    }
    
    func calculateSquareDistance(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        return pow(pointA.x - pointB.x, 2) + pow(pointA.y - pointB.y, 2)
    }
}
