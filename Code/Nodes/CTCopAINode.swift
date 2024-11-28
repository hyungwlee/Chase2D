//
//  CTCopAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/7/24.
//

import SpriteKit
import GameplayKit

class CTCopAINode: SKNode{
    
    weak var context: CTGameContext?
    
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateAI (){
        
        // timer
        let wait = SKAction.wait(forDuration: 2)
        let run = SKAction.run {
            self.spawnCops()
        }
        
        let sequence = SKAction.sequence([wait, run])
        let repeatAction = SKAction.repeatForever(sequence)
        self.run(repeatAction)
        
    }
    
    // conditions
    // player is inside a certain radius of the node
    // randomized spawn each 2 sec
    
    func spawnCops(){
        
        let checkPointsHolder = childNode(withName: "CopCarSpawners")
        
        guard let checkPointsHolder else { fatalError("CopCarCheckpoints not found") }
        
        for child in checkPointsHolder.children{
            
            let distanceWithPlayer = calculateSquareDistance(pointA: child.position, pointB: context?.gameScene?.playerCarEntity?.carNode.position ?? CGPoint(x: 0,y: 0))
            
            // random number generation
            let randomNumber = GKRandomDistribution(lowestValue: 0, highestValue: 2).nextInt()
            
            let minSpawnDist = context?.gameScene?.gameInfo?.MIN_SPAWN_RADIUS ?? 10000
            let maxSpawnDist = context?.gameScene?.gameInfo?.MAX_SPAWN_RADIUS ?? 50000
            
            // 1 in 3 chance of getting a spawn
            if
                randomNumber != 2
                || distanceWithPlayer * distanceWithPlayer >= maxSpawnDist * maxSpawnDist
                || distanceWithPlayer * distanceWithPlayer <= minSpawnDist * maxSpawnDist
                    || context?.gameScene?.gameInfo?.numberOfCops ?? 0 >= context?.gameScene?.gameInfo?.MAX_NUMBER_OF_COPS ?? 10
            { continue };
            
            context?.gameScene?.gameInfo?.numberOfCops += 1
            
//            let copCar = CTCopNode(imageNamed: "black", size:
            let copCar = CTCopNode(imageNamed: "squadCar", size:
                                    (self.context?.layoutInfo.playerCarSize) ?? CGSize(width: 5.2, height: 12.8))
            copCar.position = child.position
            copCar.name = "cop"
            
            let carEntity = CTCopCarEntity(carNode: copCar)
            carEntity.prepareComponents()
            
            context?.gameScene?.addChild(copCar)
            context?.gameScene?.copCarEntities.append(carEntity)
        }
    }
    
    func calculateSquareDistance(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        return pow(pointA.x - pointB.x, 2) + pow(pointA.y - pointB.y, 2)
    }
}
