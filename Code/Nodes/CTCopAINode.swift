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
        let wait = SKAction.wait(forDuration: 3)
        let run = SKAction.run {
            guard let context = self.context else { return }
            guard let gameScene = context.gameScene else { return }
           
            // calculates how many more cops we need for the wave
            let inSceneCopDifference = gameScene.gameInfo.MAX_NUMBER_OF_COPS - gameScene.gameInfo.numberOfCops
            if inSceneCopDifference != 0 {
                self.spawnCop()
            }
        }
        
        let sequence = SKAction.sequence([wait, run])
        let repeatAction = SKAction.repeatForever(sequence)
        self.run(repeatAction)
        
    }
    
    // uses an effecient way of capturing the nodes around the player outside a certain rectangle
    func getNodesAround() -> [SKNode] {
        guard let context else { return []}
        guard let gameScene = context.gameScene else { return []}
        
        let playerNode = gameScene.playerCarEntity?.carNode
        let playerPosition = playerNode?.position ?? CGPoint(x: 0.0, y: 0.0)
        let radius = gameScene.gameInfo.COP_SPAWN_RADIUS
        var nearbyNodes: [SKNode] = []
        
        let queryRect = CGRect(x: playerPosition.x - radius, y: playerPosition.y - radius, width: radius * 2, height: radius * 2)
        
        gameScene.physicsWorld.enumerateBodies(in: queryRect) {  body, _ in
            if let node = body.node, node != playerNode,
               !(["alley", "parking", "road"].contains(node.name))
            {
                nearbyNodes.append(node)
            }
        }
        return nearbyNodes
    }
    
    // returns a random spawn point around a radius
    // makes sure the point doesn't overlap with any existing object in the scene
    func getRandomSpawnPoint() -> CGPoint {
        
        guard let gameScene = context?.gameScene else { return CGPoint(x: 0.0, y: 0.0)}
        let playerPosition = gameScene.playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0)
        var spawnPoint: CGPoint
        var isOverlapping = false
        
        repeat {
            // we calculate this because getNodesAround returns nodes outside a certain rectangle.
            // we can find the hypot using the sides of that rect to calculate the spawn radius of our spawn circle
            let spawnRadius = hypot(gameScene.gameInfo.COP_SPAWN_RADIUS, gameScene.gameInfo.COP_SPAWN_RADIUS)
            
            // use polar coordinate to generate a spawn point based on
            let randomAngle = Double(GKRandomDistribution(lowestValue: 0, highestValue: 359).nextInt()) / 180 * .pi
            let spawnPointX = spawnRadius * cos(randomAngle)
            let spawnPointY = spawnRadius * sin(randomAngle)
            
            spawnPoint = CGPoint(x: spawnPointX + playerPosition.x, y: spawnPointY + playerPosition.y)
            
            // Create a frame for the new spawn position
            let spawnRect = CGRect(
                x: spawnPoint.x - gameScene.gameInfo.layoutInfo.copCarSize.width / 2,
                y: spawnPoint.y - gameScene.gameInfo.layoutInfo.copCarSize.height / 2,
                width: gameScene.gameInfo.layoutInfo.copCarSize.width,
                height: gameScene.gameInfo.layoutInfo.copCarSize.height
            )
                        
            isOverlapping = false
            for nodeAround in getNodesAround() {
                if spawnRect.intersects(nodeAround.frame) {
                    isOverlapping = true
                    break
                }
            }
            
        } while isOverlapping
        
        return spawnPoint
    }
    
    func spawnCop(){
        
        guard let context else { return }
        guard let gameScene = context.gameScene else { return }
       
        // calculates how many more cops we need for the wave
        let inSceneCopDifference = gameScene.gameInfo.MAX_NUMBER_OF_COPS - gameScene.gameInfo.numberOfCops
        if inSceneCopDifference == 0 { return }
        
        let spawnPoint = getRandomSpawnPoint()
        gameScene.gameInfo.numberOfCops += 1
        
        if(gameScene.gameInfo.currentWave == 0) {
             //            let copCar = CTCopNode(imageNamed: "black", size:
            let copCar = CTCopCarNode(imageNamed: "squadCar", size: context.layoutInfo.copCarSize)
            copCar.position = spawnPoint
            copCar.name = "cop"
            
            let carEntity = CTCopCarEntity(carNode: copCar)
            carEntity.gameInfo = gameScene.gameInfo
            carEntity.prepareComponents()
             
            
            if let arrestingComponent = carEntity.component(ofType: CTArrestingCopComponent.self) {
                let cop = CTCopNode(imageName: "black", size: gameScene.layoutInfo.copSize)
                let copEntity = CTCopEntity(cop: cop)
                copEntity.gameInfo = gameScene.gameInfo
                copEntity.prepareComponents()
                
                arrestingComponent.copEntity = copEntity
                arrestingComponent.gameScene = gameScene
                
                gameScene.copEntities.append(copEntity)
                
            }
           
            gameScene.addChild(copCar)
            gameScene.copCarEntities.append(carEntity)
            
        } else if gameScene.gameInfo.canSpawnPoliceTrucks && gameScene.gameInfo.currentWave >= 1 {
            //            let copCar = CTCopNode(imageNamed: "black", size:
            let copCar = CTCopTruckNode(imageNamed: "copTruck2", size: context.layoutInfo.copTruckSize)
            copCar.position = spawnPoint
            copCar.name = "cop"
            
            let carEntity = CTCopTruckEntity(carNode: copCar)
            carEntity.gameInfo = context.gameScene?.gameInfo
            carEntity.prepareComponents()
            
            if let arrestingComponent = carEntity.component(ofType: CTArrestingCopComponent.self) {
                let cop = CTCopNode(imageName: "black", size: gameScene.layoutInfo.copSize)
                let copEntity = CTCopEntity(cop: cop)
                copEntity.gameInfo = gameScene.gameInfo
                copEntity.prepareComponents()
                
                arrestingComponent.copEntity = copEntity
                arrestingComponent.gameScene = gameScene
                
                gameScene.copEntities.append(copEntity)
                
            }
            
            gameScene.addChild(copCar)
            gameScene.copTruckEntities.append(carEntity)
        }
        // spawn trucks and tanks
        if(gameScene.gameInfo.canSpawnTanks &&
           (gameScene.gameInfo.currentWave >= 3)) {
            //            let copCar = CTCopNode(imageNamed: "black", size:
            let copCar = CTCopTankNode(imageNamed: "tank1", size: context.layoutInfo.copTankSize)
            copCar.position = spawnPoint
            copCar.name = "cop"
            
            let carEntity = CTCopTankEntity(carNode: copCar)
            carEntity.gameInfo = context.gameScene?.gameInfo
            carEntity.prepareComponents()
            
            gameScene.addChild(copCar)
            gameScene.copTankEntities.append(carEntity)
        }
    }
}
