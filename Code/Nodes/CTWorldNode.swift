//
//  CTWorldNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import SpriteKit

class CTWorldNode: SKSpriteNode{
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        texture?.filteringMode = .nearest
    }
}
