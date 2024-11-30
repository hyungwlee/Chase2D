
//
//  CTObstacleNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/1/24.
//

import SpriteKit

class CTObstacleNode: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        texture?.filteringMode = .nearest
        physicsBody?.categoryBitMask = CTPhysicsCategory.building
        physicsBody?.contactTestBitMask = CTPhysicsCategory.car | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck
        physicsBody?.collisionBitMask = CTPhysicsCategory.car | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck
    }
}
