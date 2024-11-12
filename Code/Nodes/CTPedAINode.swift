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
        
        for (index, child) in checkPointsHolder.children.enumerated(){
            let pedCar = CTPedCarNode(imageNamed: "yelow", size: (self.context?.layoutInfo.playerCarSize) ?? CGSize(width: 5.2, height: 12.8))
            pedCar.position = child.position
            
            let pedCarEntity = CTPedCarEntity(carNode: pedCar)
            pedCarEntity.checkPointsList = checkPointsHolder.children
            pedCarEntity.currentTargetIndex = index + 1
            pedCarEntity.currentTarget = child.position
            
            context?.gameScene?.addChild(pedCar)
            context?.gameScene?.pedCarEntities.append(pedCarEntity)
        }
        
       
    }
}
