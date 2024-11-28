import SpriteKit

class CTCarNode: SKSpriteNode{
    
    var STEER_IMPULSE = 0.05
    var MOVE_FORCE:CGFloat = 1300
    var DRIFT_FORCE:CGFloat = 1000
    var DRIFT_VELOCITY_THRESHOLD: CGFloat = 6
    
    var health = 100.0
    
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
//            physicsBody = SKPhysicsBody(texture: self.texture ?? SKTexture(imageNamed: "black"), size: self.size)
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
        physicsBody?.collisionBitMask = CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.enemy | CTPhysicsCategory.car
        physicsBody?.contactTestBitMask = CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.enemy | CTPhysicsCategory.car
    }
    
    public func calculateAngle(pointA: CGPoint, pointB: CGPoint) -> CGFloat{
        let a1 = atan(pointA.y / pointA.x) < 0 ? .pi + atan(pointA.y / pointA.x) : atan(pointA.y / pointA.x)
        let a2 = atan(pointB.y / pointB.x) < 0 ? .pi + atan(pointB.y / pointB.x) : atan(pointB.y / pointB.x)
        
        return a2 - a1
    }
    
    public func calculateSquareDistance(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        return pow(pointA.x - pointB.x, 2) + pow(pointA.y - pointB.y, 2)
    }
}
