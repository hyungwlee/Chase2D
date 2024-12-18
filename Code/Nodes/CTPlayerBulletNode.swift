//
//  CTPlayerBulletNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/17/24.
//
import SpriteKit

class CTPlayerBulletNode: SKSpriteNode {
    
    init(imageNamed: String, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed )
        texture.filteringMode = .nearest
        super.init(texture: texture, color: .clear, size: size)
        
        enablePhysics()
    }
    
    func enablePhysics(){
        if(physicsBody == nil){
            physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.0)
            physicsBody?.isDynamic = true
            physicsBody?.affectedByGravity = false
            physicsBody?.mass = 300
            physicsBody?.friction = 0
            physicsBody?.categoryBitMask = CTPhysicsCategory.playerBullet
            physicsBody?.contactTestBitMask = CTPhysicsCategory.copCar | CTPhysicsCategory.ped | CTPhysicsCategory.copTruck | CTPhysicsCategory.copTank | CTPhysicsCategory.building
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not implemented")
    }
}
