import SpriteKit

class CTCarNode: SKSpriteNode {

    init(){
        let texture = SKTexture(imageNamed: "Truck0")
        texture.filteringMode = .nearest
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemended")
    }
    
    func setup(screenSize: CGSize){
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
}
