//
//  CTCopAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/7/24.
//

import SpriteKit

class CTCopAINode: SKNode{
    
    weak var context: CTGameContext?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateAI (){
        
        let checkPointsHolder = childNode(withName: "CopCarSpawners")
        
        guard let checkPointsHolder else { fatalError("CopCarCheckpoints not found") }
        
        for child in checkPointsHolder.children{
            let copCar = CTCopNode(imageNamed: "black", size: (self.context?.layoutInfo.playerCarSize) ?? CGSize(width: 5.2, height: 12.8))
            copCar.player = context?.gameScene?.playerCarNode
            copCar.position = child.position
            context?.gameScene?.addChild(copCar)
            context?.gameScene?.copCars.append(copCar)
        }
        
       
    }
}
