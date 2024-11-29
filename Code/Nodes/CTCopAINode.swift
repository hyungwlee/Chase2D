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
        let wait = SKAction.wait(forDuration: 0.5)
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
        
        guard let context else { return }
        guard let gameScene = context.gameScene else { return }
        
        let checkPointsHolder = childNode(withName: "CopCarSpawners")
        
        guard let checkPointsHolder else { fatalError("CopCarCheckpoints not found") }
        
        for child in checkPointsHolder.children{
            
            let distanceWithPlayer = calculateSquareDistance(pointA: child.position, pointB: gameScene.playerCarEntity?.carNode.position ?? CGPoint(x: 0,y: 0))
            
            // random number generation
            let randomNumber = GKRandomDistribution(lowestValue: 0, highestValue: 2).nextInt()
            

            let minSpawnDist = context.gameScene?.gameInfo.MIN_SPAWN_RADIUS ?? 10000
            let maxSpawnDist = context.gameScene?.gameInfo.MAX_SPAWN_RADIUS ?? 50000
            
            // 1 in 3 chance of getting a spawn
            if
                randomNumber != 2
                || distanceWithPlayer * distanceWithPlayer >= maxSpawnDist * maxSpawnDist
                || distanceWithPlayer * distanceWithPlayer <= minSpawnDist * maxSpawnDist

                || context.gameScene?.gameInfo.numberOfCops ?? 0 >= context.gameScene?.gameInfo.MAX_NUMBER_OF_COPS ?? 10
            { continue };
            
            gameScene.gameInfo.numberOfCops += 1
            
            if(gameScene.gameInfo.currentWave == 0) {
                 //            let copCar = CTCopNode(imageNamed: "black", size:
                let copCar = CTCopNode(imageNamed: "squadCar", size: context.layoutInfo.copCarSize)
                copCar.position = child.position
                copCar.name = "cop"
                
                let carEntity = CTCopCarEntity(carNode: copCar)
                carEntity.gameInfo = gameScene.gameInfo
                carEntity.prepareComponents()
                
                gameScene.addChild(copCar)
                gameScene.copCarEntities.append(carEntity)
                
            } else if(gameScene.gameInfo.canSpawnPoliceTrucks &&
               (gameScene.gameInfo.currentWave == 1 ||
                gameScene.gameInfo.currentWave >= 2)) {
                //            let copCar = CTCopNode(imageNamed: "black", size:
                let copCar = CTCopTruckNode(imageNamed: "copTruck2", size: context.layoutInfo.copTruckSize)
                copCar.position = child.position
                copCar.name = "cop"
                
                let carEntity = CTCopTruckEntity(carNode: copCar)
                carEntity.gameInfo = context.gameScene?.gameInfo
                carEntity.prepareComponents()
                
                gameScene.addChild(copCar)
                gameScene.copTruckEntities.append(carEntity)
            }
            // spawn trucks and tanks
            if(gameScene.gameInfo.canSpawnTanks &&
               (gameScene.gameInfo.currentWave >= 3)) {
                //            let copCar = CTCopNode(imageNamed: "black", size:
                let copCar = CTCopTankNode(imageNamed: "tank1", size: context.layoutInfo.copTankSize)
                copCar.position = child.position
                copCar.name = "cop"
                
                let carEntity = CTCopTankEntity(carNode: copCar)
                carEntity.gameInfo = context.gameScene?.gameInfo
                carEntity.prepareComponents()
                
                gameScene.addChild(copCar)
                gameScene.copTankEntities.append(carEntity)
            }
            

        }
    }
    
    func calculateSquareDistance(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        return pow(pointA.x - pointB.x, 2) + pow(pointA.y - pointB.y, 2)
    }
}
