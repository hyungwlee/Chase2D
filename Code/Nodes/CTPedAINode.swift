//
//  CTPedAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/5/24.
//

import SpriteKit

class CTPedAINode: SKNode{
    
    weak var context: CTGameContext?
    let spriteArray = ["pedCar1", "pedCar2", "pedCar3", "pedTruck1", "pedTruck2"]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateAI (){
        
        let checkPointsHolder = childNode(withName: "PedCarCheckpoints")
        
        guard let checkPointsHolder else { fatalError("PedCarCheckpoints not found") }
        
        for (index, child) in checkPointsHolder.children.enumerated(){
            let sprite = spriteArray[Int.random(in: 0...4)]
            let pedCar = CTPedCarNode(imageNamed: sprite, size: (self.context?.layoutInfo.playerCarSize) ?? CGSize(width: 5.2, height: 12.8))
            pedCar.position = child.position
            
            let pedCarEntity = CTPedCarEntity(carNode: pedCar)
            pedCarEntity.prepareComponents()
            pedCarEntity.checkPointsList = checkPointsHolder.children
            pedCarEntity.currentTargetIndex = index + 1
            pedCarEntity.currentTarget = child.position
            
            context?.gameScene?.addChild(pedCar)
            context?.gameScene?.pedCarEntities.append(pedCarEntity)
        }
        
       
    }
}
