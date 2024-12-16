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
    var label: SKLabelNode?
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
        
        let radius:CGFloat = 25.0
        
        if !addedArrowToScene {
            
            arrow = CTArrowNode(imageName: "gasArrow", size: gameScene.layoutInfo.pickUpPointArrow)
            arrow?.size = CGSize(width: 20.0, height: 20.0)
            arrow?.zPosition = 100
            gameScene.addChild(arrow!)
            
            label = SKLabelNode(text: "Gas")
            label?.setScale(0.25)
            label?.zPosition = 100
            label?.fontName = "Eating Pasta"
            label?.fontColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0)
            gameScene.addChild(label!)
            
            addedArrowToScene = true
        }
        
        let angleToTarget = atan2(targetPoint.y - carNode.position.y, targetPoint.x - carNode.position.x)
        
        let targetAngle = angleToTarget - .pi / 2.0
        let polarX = cos(targetAngle + .pi / 2.0) * radius + carNode.position.x
        let polarY = sin(targetAngle + .pi / 2.0) * radius + carNode.position.y
        
        arrow?.position = CGPoint(x: polarX, y: polarY)
        label?.position = CGPoint(x: polarX, y: polarY - 15)
        arrow?.zRotation = targetAngle
    }
}
