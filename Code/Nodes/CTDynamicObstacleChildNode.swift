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
        assignNode(offset: offsetPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not found")
    }
    
    func assignNode(offset: CGPoint){
        guard let parent = self.parent else { return
            
        }
        var node:EnemyNode = CTCopNode(imageNamed: "squadCar", size: CGSize(width: 5.2, height: 12))
        
        let random = GKRandomDistribution(lowestValue: 0, highestValue: 1).nextInt()
        
        switch random {
        case 0:
            node = CTCopNode(imageNamed: "squadCar", size: CGSize(width: 5.2, height: 12))
            node.position = CGPoint(x: node.position.x + offset.x, y: node.position.y + offset.y)
            parent.addChild(node)
            break;
        case 1:
            node = CTCopTruckNode(imageNamed: "copTruck2", size: CGSize(width: 6, height: 15))
            node.position = CGPoint(x: node.position.x + offset.x, y: node.position.y + offset.y)
            parent.addChild(node)
            break;
        default:
            break;
        }
        self.removeFromParent()
        
    }
}
