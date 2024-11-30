//
//  CTDynamicObstacleNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/30/24.
//

import SpriteKit

class CTDynamicObstacleNode: SKNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        for i in 0...3 {
            let car = CTDynamicObstacleChildNode()
//            car.offsetPoint = CGPoint(x: 0, y: (-1 + i) * 20)
            print(car)
            scene?.addChild(car)
        }
    }
}
