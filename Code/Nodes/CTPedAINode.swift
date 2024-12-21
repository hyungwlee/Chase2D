//
//  CTPedAINode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/5/24.
//

import SpriteKit

class CTPedAINode: SKNode{
    
    weak var context: CTGameContext?
    let spriteArray = ["CTpedCar1", "CTpedCar2", "CTpedCar3", "CTpedTruck1", "CTpedTruck2"]
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error")
    }
    
    func setupPedestrianCars() {
        guard let gameScene = context?.gameScene else { return }
        // Define the path points for pedestrian cars
        let pathNodes = gameScene.children.filter { $0.name?.starts(with: "CTPedCheckpoint") == true }
        print(pathNodes)
        let sortedNodes = pathNodes.sorted {
            let num1 = Int($0.name?.filter { $0.isNumber } ?? "") ?? 0
            let num2 = Int($1.name?.filter { $0.isNumber } ?? "") ?? 0
            return num1 < num2
        }
        let pathPoints = sortedNodes.map { $0.position }
        
        guard !pathPoints.isEmpty else { return }
        
        // Spawn a pedestrian car at each node and make it follow the path
        for nodePosition in pathPoints {
            spawnPedestrianCar(at: nodePosition, following: pathPoints)
        }
    }

    func spawnPedestrianCar(at position: CGPoint, following pathPoints: [CGPoint]) {
        
        guard let gameScene = context?.gameScene else { return }
        let sprite = spriteArray[Int.random(in: 0...4)]
        let pedCarNode = CTPedCarNode(imageNamed: sprite, size: (self.context?.layoutInfo.playerCarSize) ?? CGSize(width: 5.2, height: 12.8))
        pedCarNode.name = "ped"
        pedCarNode.position = position
        gameScene.addChild(pedCarNode)
        
        // Make the pedestrian car follow the path in a loop
        movePedestrianCar(pedCarNode, along: pathPoints)
    }

    func movePedestrianCar(_ pedCarNode: SKSpriteNode, along pathPoints: [CGPoint]) {
        guard !pathPoints.isEmpty else { return }

        // Find the closest starting point for this pedestrian car
        let startIndex = pathPoints.enumerated().min(by: {
            pedCarNode.position.distance(to: $0.1) < pedCarNode.position.distance(to: $1.1)
        })?.0 ?? 0

        // Reorder the pathPoints to start from the closest point
        let reorderedPathPoints = Array(pathPoints[startIndex...] + pathPoints[..<startIndex])

        // Create actions to move along the reordered path points
        var actions: [SKAction] = []
        var previousPosition = pedCarNode.position // Start with the car's initial position
        
        for targetPoint in reorderedPathPoints {
            // Calculate the angle to rotate towards the next point
            let deltaX = targetPoint.x - previousPosition.x
            let deltaY = targetPoint.y - previousPosition.y
            let targetAngle = atan2(deltaY, deltaX) // Angle in radians toward the target point
            
            // Update previous position
            let distance = previousPosition.distance(to: targetPoint)
            
            previousPosition = targetPoint

            // Create actions for rotation and movement
            let rotateAction = SKAction.rotate(toAngle: targetAngle - .pi / 2.0, duration: 0.2, shortestUnitArc: true)
            let moveAction = SKAction.move(to: targetPoint, duration: 0.01 * distance)
            let groupAction = SKAction.group([rotateAction, moveAction])

            actions.append(groupAction)
        }

        // Loop through the reordered path forever
        let sequence = SKAction.sequence(actions)
        let repeatAction = SKAction.repeatForever(sequence)
        pedCarNode.run(repeatAction)
    }

}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}
