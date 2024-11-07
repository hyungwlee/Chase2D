//
//  CTPedAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/5/24.
//

import SpriteKit

class CTPedAINode: SKNode{
    
    weak var context: CTGameContext?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateAI (){
        
        let checkPointsHolder = childNode(withName: "PedCarCheckpoints")
        
        guard let checkPointsHolder else { fatalError("PedCarCheckpoints not found") }
        
        for child in checkPointsHolder.children{
            let pedCar = CTPedCarNode(imageNamed: "yelow", size: CGSize(width: 5.2, height: 12.8))
            pedCar.checkPointsList = checkPointsHolder.children
            pedCar.position = child.position
//        pedCar.position = checkPointsHolder.children[0].position
            context?.gameScene?.addChild(pedCar)
            context?.gameScene?.pedCars.append(pedCar)
        }
        
       
    }
}
