//  CTGameScene.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/26/24.
//

import SpriteKit
import GameplayKit

class CTGameScene: SKScene {
    weak var context: CTGameContext?
    
    var playerCarNode: CTCarNode?
    var pedCarSpawner: CTPedAINode?
    var copCarSpawner: CTCopAINode?
    var pedCars: [CTPedCarNode] = []
    var copCars: [CTCopNode] = []
    var cameraNode: SKCameraNode?
    var gameInfo: CTGameInfo
    
    required init?(coder aDecoder: NSCoder) {
        self.gameInfo = CTGameInfo()
        super.init(coder: aDecoder)
        self.view?.isMultipleTouchEnabled = true
//        fatalError("init(coder:) has not been implemented")
        self.addChild(gameInfo.scoreLabel)
        self.addChild(gameInfo.timeLabel)
        self.addChild(gameInfo.healthLabel)
    }

//    init(context: CTGameContext, size: CGSize) {
//        self.context = context
//        super.init(size: size)
//    }
        
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        physicsWorld.contactDelegate = self
        
        view.showsFPS = true
        view.showsPhysics = true
        
        prepareGameContext()
        prepareStartNodes()
        
        
       
        context.stateMachine?.enter(CTGameIdleState.self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if(playerCarNode?.health ?? 100 <= 0.0){
            context?.stateMachine?.enter(CTGameOverState.self)
        }
        context?.stateMachine?.update(deltaTime: currentTime)
        gameInfo.updateScore(phoneRuntime: currentTime)
        
        gameInfo.scoreLabel.position = CGPoint(x: cameraNode!.position.x - 50, y: cameraNode!.position.y - 50)
        gameInfo.timeLabel.position = CGPoint(x: cameraNode!.position.x - 50, y: cameraNode!.position.y - 75)
        gameInfo.healthLabel.position = CGPoint(x: cameraNode!.position.x - 50, y: cameraNode!.position.y - 100)
        
        // ped car drive
        
        for pedCar in pedCars{
            pedCar.drive(driveDir: .forward)
        }
        
        for copCar in copCars{
            copCar.drive(driveDir: .forward)
        }
        
        gameInfo.setHealthLabel(value: playerCarNode!.health)
    }
    
    func prepareGameContext(){
    
        guard let context else {
            return
        }

        context.scene = scene
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {
            return
        }
        
        let center = CGPoint(x: size.width / 2.0 - context.layoutInfo.playerCarSize.width / 2.0,
                             y: size.height / 2.0)
         // set player car from scene
        playerCarNode = CTCarNode(imageNamed: "red", size: CGSize(width: 5.2, height: 12.8))
        scene?.addChild(playerCarNode ?? CTCarNode(imageNamed: "red", size: CGSize(width: 5.2, height: 12.8)))
        
        // spawns ped cars
        pedCarSpawner = self.childNode(withName: "PedAI") as? CTPedAINode
        pedCarSpawner?.context = self.context
        pedCarSpawner?.populateAI()
        
        // spawns cop cars
        copCarSpawner = self.childNode(withName: "CopAI") as? CTCopAINode
        copCarSpawner?.context = self.context
        copCarSpawner?.populateAI()
        
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        addChild(cameraNode)
        self.cameraNode = cameraNode
        camera = self.cameraNode
        
        let zoomInAction = SKAction.scale(to: 1, duration: 0.2)
        cameraNode.run(zoomInAction)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouchStart(touches)
    }
    
    // only for testing purpose
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouchEnded(touch)
    }
}


extension CTGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let categoryA = contact.bodyA.categoryBitMask
        let categoryB = contact.bodyB.categoryBitMask
        
        let collision = categoryA | categoryB
        
        if collision == (CTPhysicsCategory.collidableObstacle | CTPhysicsCategory.collidableObstacle){
            let carNode = (contact.bodyA.categoryBitMask == CTPhysicsCategory.collidableObstacle) ? contact.bodyA.node as? CTCarNode : contact.bodyB.node as? CTCarNode
            
            
            let carVelocityMag:CGFloat = pow(carNode?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(carNode?.physicsBody?.velocity.dy ?? 0.0, 2)
            carNode?.health -= carVelocityMag * 0.001
        }
        
    }
}
