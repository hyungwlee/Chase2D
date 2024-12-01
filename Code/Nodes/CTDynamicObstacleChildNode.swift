//
//  CTDynamicObstacleChildNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/30/24.
//

import SpriteKit
import GameplayKit


class CTDynamicObstacleChildNode: SKNode {
    var offsetPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not found")
    }
    

}
