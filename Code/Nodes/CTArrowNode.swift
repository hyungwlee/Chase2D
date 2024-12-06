//
//  CTArrowNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/6/24.
//

import SpriteKit

class CTArrowNode: SKSpriteNode{
    init(imageName: String, size: CGSize) {
        let texture = SKTexture(imageNamed: imageName)
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
