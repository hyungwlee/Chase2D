//
//  CTDynamicObstacleNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/30/24.
//

import SpriteKit
import GameplayKit

class CTDynamicObstacleNode: SKNode {
        
    var context: CTGameContext?
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    func assignNode(offset: CGPoint){
        print("context not set")
        guard let context else {return}
        print("context set")
        var copCar:EnemyNode = CTCopCarNode(imageNamed: "CTsquadCar", size: context.layoutInfo.copCarSize)
        
        let random = GKRandomDistribution(lowestValue: 0, highestValue: 1).nextInt()
        
        switch random {
        case 0:
            copCar = CTCopCarNode(imageNamed: "CTsquadCar", size: context.layoutInfo.copCarSize)
            copCar.position = position
            copCar.name = "cop"
           print("added")
            context.gameScene?.addChild(copCar)
            
            break;
        case 1:
            copCar = CTCopTruckNode(imageNamed: "CTcopTruck2", size: context.layoutInfo.copTruckSize)
            copCar.position = position
            copCar.name = "cop"
            
           print("added")
            context.gameScene?.addChild(copCar)
            break;
        default:
            break;
        }
    }
}
