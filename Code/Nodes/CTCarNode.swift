import SpriteKit

class CTCarNode: SKSpriteNode {
    
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
        self.physicsBody?.mass = 100.0
        self.physicsBody?.friction = 1.0
        self.physicsBody?.affectedByGravity = false
    }
}
