import SpriteKit

class CTCarNode: SKSpriteNode {
    
    let STEER_IMPULSE = 0.03
    let MOVE_FORCE:CGFloat = 80
    
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
    
    func setup(screenSize: CGSize){
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
    
    func enablePhysics(){
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 10 // Adjust for realistic movement
        self.physicsBody?.friction = 10
        self.physicsBody?.restitution = 5 // Controls bounciness
        self.physicsBody?.angularDamping = 10 // Dampen rotational movement
        self.physicsBody?.linearDamping = 10 // Dampen forward movement slightly
    }
    
    func steer(moveDirection: CGFloat){
        self.physicsBody?.applyAngularImpulse(moveDirection * STEER_IMPULSE * -1.0);
    }
    
    func drive(){
        print(self.zRotation)
        let directionX = -sin(self.zRotation) * MOVE_FORCE
        let directionY = cos(self.zRotation) * MOVE_FORCE
        
        let force = CGVector(dx: directionX, dy: directionY)
        physicsBody?.applyImpulse(force)
        
    }
}
