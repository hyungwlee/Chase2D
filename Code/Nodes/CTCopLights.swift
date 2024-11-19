//
//  CTCopLights.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/15/24.
//

import SpriteKit

class CTCopLights: SKSpriteNode {
    
    init(offset: CGPoint, size: CGSize){
        super.init(texture: nil, color: .blue, size: size)
        
        startFlashing()
        
        self.position = CGPoint(x: self.position.y + offset.x, y: self.position.y + offset.y)
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not initialized")
    }
   
    func startFlashing(){
        
        let lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 1.0
        lightNode.lightColor = .blue
        self.addChild(lightNode)
        
        let flashBlue = SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 0.1)
        let flashRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1)
        let flashSequence = SKAction.sequence([flashBlue, flashRed])
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        
        
        let flashingAndPulsing = SKAction.group([flashSequence, pulseSequence])
        
        self.run(SKAction.repeatForever(flashingAndPulsing))
        
    }
    
    
    
}
