//  CTGameScene.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/26/24.
//

import SpriteKit
import GameplayKit

class CTGameScene: SKScene {
    weak var context: CTGameContext?
    
    var playerCarEntity: CTPlayerCarEntity?
    var pedCarSpawner: CTPedAINode?
    var copCarSpawner: CTCopAINode?
    var pedCarEntities: [CTPedCarEntity] = []
    var copCarEntities: [CTCopCarEntity] = []
    var cameraNode: SKCameraNode?
    var gameInfo: CTGameInfo
    var layoutInfo: CTLayoutInfo
    
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var timeLabel = SKLabelNode(fontNamed: "Arial")
    var healthLabel = SKLabelNode(fontNamed: "Arial")
    var gameOverLabel = SKLabelNode(fontNamed: "Arial")
    
    var healthIndicator = SKSpriteNode(imageNamed: "player100")
    var speedometer = SKSpriteNode(imageNamed: "speedometer")
    var speedometerBG = SKSpriteNode(imageNamed: "speedometerBG")
    
    
    let GAME_SPEED_INCREASE_RATE = 0.01
    
    
    required init?(coder aDecoder: NSCoder) {
//        self.gameInfo = gameInfo
//        self.layoutInfo = layoutInfo
        super.init(coder: aDecoder)
        self.view?.isMultipleTouchEnabled = true
        
//        Text UI Elements
        scoreLabel.fontSize = 6
        scoreLabel.zPosition = 100
        
        timeLabel.fontSize = 6
        timeLabel.zPosition = 100
        
        healthLabel.fontSize = 8
        healthLabel.zPosition = 100
        
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.isHidden = true
        gameOverLabel.fontSize = 12
        gameOverLabel.zPosition = 100
        
//        Non-Text UI Elements
        healthIndicator.size = context!.layoutInfo.healthIndicatorSize
        healthIndicator.alpha = 0.5
        healthIndicator.zPosition = 90
        
        speedometer.size = context!.layoutInfo.speedometerSize
        speedometer.zPosition = 100
        
        speedometerBG.size = context!.layoutInfo.speedometerBackgroundSize
        speedometerBG.zPosition = 95
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        
        // for collision
        physicsWorld.contactDelegate = self
        
        view.showsFPS = true
        view.showsPhysics = true
        
        prepareGameContext()
        prepareStartNodes()
        
        context.stateMachine?.enter(CTGamePlayState.self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        
        if(gameInfo.gameOver)
        {
            context?.stateMachine?.enter(CTGameOverState.self)
            gameOverLabel.isHidden = false
            healthIndicator.isHidden = true
        }
        context?.stateMachine?.update(deltaTime: currentTime)
        
        let camX = cameraNode!.position.x
        let camY = cameraNode!.position.y
        
        //REVISED SCORE AND TIME FUNCTION CALLS
        gameInfo.updateTime(phoneRuntime: currentTime)
        gameInfo.updateScore()
        
        // Text UI Components
        scoreLabel.text = "Score: " + String(gameInfo.score)
        timeLabel.text = "Time: " + String(Int(gameInfo.seconds))
        healthLabel.text = "Health: " + String(Int(gameInfo.playerHealth))
        
        //SHIFTS IN POSITION NEED TO BE RELATIVE TO SCREENSIZE
        scoreLabel.position = CGPoint(x: camX + 15, y: camY + 90)
        timeLabel.position = CGPoint(x: camX - 15, y: camY + 90)
        gameOverLabel.position = CGPoint(x: camX, y: camY + 50)
        healthLabel.position = CGPoint(x: camX + 40, y: camY - 80 )
        
        // Non-text UI components
        let velocity = playerCarEntity?.carNode.physicsBody?.velocity ?? CGVector(dx: 0.0, dy: 0.0)
        // TODO: try not to use sqrt because of performance issues
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        
        healthIndicator.position = CGPoint(x: camX + 45, y: camY - 50)
        speedometer.position = CGPoint(x: camX, y: camY - 100)
        speedometerBG.position = CGPoint(x: camX + gameInfo.updateSpeed(speed: speed), y: camY - 100)
        
        healthIndicator.texture = gameInfo.updateHealthUI()
        
        // ai section
        updateCopCarComponents()
        updatePedCarComponents()
        
        
        // spawn powerup section
        
        // spawn more cash if cash is low
        if(gameInfo.numberOfCashNodesInScene < 20){
            spawnCashNodes(amount:gameInfo.initialCashNumber)
            gameInfo.numberOfCashNodesInScene = gameInfo.numberOfCashNodesInScene + gameInfo.initialCashNumber
        }
    }
    
    func updatePedCarComponents(){

        for pedCarEntity in pedCarEntities {
            
            pedCarEntity.updateCurrentTarget()
            
             if let trackingComponent = pedCarEntity.component(ofType: CTSelfDrivingComponent.self) {
                 trackingComponent.follow(target: pedCarEntity.currentTarget)
                trackingComponent.avoidObstacles()
            }
            if let drivingComponent = pedCarEntity.component(ofType: CTDrivingComponent.self) {
                drivingComponent.drive(driveDir: .forward)
            }
        }
    }
    
    func updateCopCarComponents(){
        // copCar drive
        for copCarEntity in copCarEntities{
            
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(pointA: copCarEntity.carNode.position, pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)) ?? 0
            
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copCarEntity.carNode.removeFromParent()
                if let index =  copCarEntities.firstIndex(of: copCarEntity) {
                    copCarEntities.remove(at: index)
                }
                gameInfo.numberOfCops -= 1
                continue;
            }
            
            if let trackingComponent = copCarEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copCarEntity.component(ofType: CTDrivingComponent.self) {
                drivingComponent.drive(driveDir: .forward)
            }
        }
    }
    
    func spawnCashNodes(amount: Int){
        guard let context else { return }
        
        let randomSource = GKRandomSource.sharedRandom()
        
        for _ in 0...amount {
            let randomFloatX = Double(randomSource.nextUniform()) * gameInfo.MAX_PLAYABLE_SIZE - gameInfo.MAX_PLAYABLE_SIZE / 2.0
            let randomFloatY = Double(randomSource.nextUniform()) * gameInfo.MAX_PLAYABLE_SIZE - gameInfo.MAX_PLAYABLE_SIZE / 2.0
            
            let cashNode = CTPowerUpNode(imageNamed: "scoreBoost", nodeSize: context.layoutInfo.powerUpSize)
            cashNode.name = "cash"
            cashNode.position = CGPoint(x: randomFloatX, y: randomFloatY)
            cashNode.zPosition = -1
            addChild(cashNode)
            
        }
    }
    
    func prepareGameContext(){
        guard let context else {
            return
        }

        context.scene = scene
        context.configureLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {
            return
        }
        
        // set player car from scene
//        let playerCarNode = CTCarNode(imageNamed: "red", size: (context.layoutInfo.playerCarSize) )
        let playerCarNode = CTCarNode(imageNamed: "playerCar", size: (context.layoutInfo.playerCarSize) )
        playerCarEntity = CTPlayerCarEntity(carNode: playerCarNode)
        playerCarEntity?.gameInfo = gameInfo
        playerCarEntity?.prepareComponents()
        addChild(playerCarNode)
        
       
        // spawns ped cars
        pedCarSpawner = self.childNode(withName: "PedAI") as? CTPedAINode
        pedCarSpawner?.context = context
        pedCarSpawner?.populateAI()
        
        // spawns cop cars
        copCarSpawner = self.childNode(withName: "CopAI") as? CTCopAINode
        copCarSpawner?.context = context
        copCarSpawner?.populateAI()
        
        
        // camera node
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        addChild(cameraNode)
        self.cameraNode = cameraNode
        camera = self.cameraNode
        
        let zoomInAction = SKAction.scale(to: 0.3, duration: 0.2)
        // debug camera
//        let zoomInAction = SKAction.scale(to: 1, duration: 0.2)
        cameraNode.run(zoomInAction)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let state = context?.stateMachine?.currentState as? CTGamePlayState else {
            return
        }
        state.handleTouchStart(touches)
    }
    
    // only for testing purpose
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGamePlayState else {
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
        
        
        // non-damage collision
        if collision == (CTPhysicsCategory.car | CTPhysicsCategory.powerup) {
             
            let colliderNode = (contact.bodyA.categoryBitMask != CTPhysicsCategory.car) ? contact.bodyA.node : contact.bodyB.node
            // add cash if car hits a powerup and remove cash from total
            gameInfo.cashCollected = gameInfo.cashCollected + 1
            gameInfo.numberOfCashNodesInScene = gameInfo.numberOfCashNodesInScene - 1
            colliderNode?.removeFromParent()
            
            // randomly applies one powerup if we collect 5 powerup
            if(gameInfo.cashCollected == 5) {
                activatePowerUp()
                gameInfo.cashCollected = 0
            }
            
        }
        
        
        // damage collision
        if collision == (CTPhysicsCategory.car  | CTPhysicsCategory.building) ||
            collision == (CTPhysicsCategory.car | CTPhysicsCategory.enemy) ||
            collision == (CTPhysicsCategory.car | CTPhysicsCategory.ped) {
            
            let carNode = (contact.bodyA.categoryBitMask == CTPhysicsCategory.car) ? contact.bodyA.node as? CTCarNode : contact.bodyB.node as? CTCarNode
            let colliderNode = (contact.bodyA.categoryBitMask != CTPhysicsCategory.car) ? contact.bodyA.node : contact.bodyB.node
            
            
            let carVelocityMag = pow(carNode?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(carNode?.physicsBody?.velocity.dy ?? 0.0, 2)
            let colliderVelocityMag:CGFloat = pow(colliderNode?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(colliderNode?.physicsBody?.velocity.dy ?? 0.0, 2)
            
         // impact force depends on the relative velocity
               
            gameInfo.playerHealth -= abs(carVelocityMag - colliderVelocityMag) * 0.0001
            
            if(gameInfo.playerHealth <= 0){
                gameInfo.playerHealth = 0
                gameInfo.setGameOver(val: true)
            }
        }
        
    }
}

extension CTGameScene{
    
    func activatePowerUp() {
        let randomNumber = GKRandomDistribution(lowestValue: 0, highestValue: 5).nextInt()
        switch(randomNumber){
        case 0,1:
            boostHealth()
            break;
        case 2:
            destroyCops()
            break;
        case 3,4,5:
             increaseSpeed()
            break;
        default:
            break;
        }
    }
    
    func boostHealth() {
        gameInfo.playerHealth = gameInfo.playerHealth + 5
        print("boostHealth")
    }
    
    func destroyCops() {
        for copCarEntity in copCarEntities{
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            copCarEntity.carNode.run(fadeOutAction) {
                if let index =  self.copCarEntities.firstIndex(of: copCarEntity) {
                    copCarEntity.carNode.removeFromParent()
                    self.copCarEntities.remove(at: index)
                    self.gameInfo.numberOfCops -= 1
                }
            }
            
        }
        print("destoryCops")
    }
    
    func increaseSpeed() {
        gameInfo.playerSpeed = gameInfo.playerSpeed + 100
        print("increase Speed")
    }
    
}
