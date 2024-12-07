//
//  CTPickupFollowArrow.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/6/24.
//

import SpriteKit
import GameplayKit

class CTPickupFollowArrow: GKComponent {
    var arrow: SKSpriteNode?
    let carNode: DriveableNode
    var gameScene: CTGameScene?
    let radius = 20.0
    var addedArrowToScene = false
        
    init(carNode: DriveableNode) {
        self.carNode = carNode
        super.init()
    }
        
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
        
    func setTarget(targetPoint: CGPoint){
        guard let gameScene else { return }
        if !addedArrowToScene {
            
            arrow = CTArrowNode(imageName: "arrow_n", size: gameScene.layoutInfo.pickUpPointArrow)
            arrow?.zPosition = 100
            gameScene.addChild(arrow!)
            addedArrowToScene = true
        }
        
        let angleToTarget = atan2(targetPoint.y - carNode.position.y, targetPoint.x - carNode.position.x)
//        print(angleToTarget)
        arrow?.position = carNode.position
        
        // Calculate the shortest angle difference
//        var angleDifference = angleToTarget - carNode.zRotation + .pi / 2.0
//
//        if angleDifference > .pi {
//            angleDifference -= 2 * .pi
//        } else if angleDifference < -.pi {
//            angleDifference += 2 * .pi
//        }
        
        arrow?.zRotation = angleToTarget - .pi / 2.0
    }
}
