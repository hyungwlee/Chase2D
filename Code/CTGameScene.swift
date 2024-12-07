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
    var copEntities: [CTCopEntity] = []
    var copTruckEntities: [CTCopTruckEntity] = []
    var copTankEntities: [CTCopTankEntity] = []
    var cameraNode: SKCameraNode?
    var gameInfo: CTGameInfo
    var layoutInfo: CTLayoutInfo
    var playerSpeed: CGFloat = 0.0
    
    
    let GAME_SPEED_INCREASE_RATE = 0.01

    
    required init?(coder aDecoder: NSCoder) {
        self.gameInfo = CTGameInfo()
        self.layoutInfo = CTLayoutInfo(screenSize: UIScreen.main.bounds.size)
        super.init(coder: aDecoder)
        self.view?.isMultipleTouchEnabled = true
        self.addChild(gameInfo.scoreLabel)
        self.addChild(gameInfo.timeLabel)
        self.addChild(gameInfo.healthLabel)
        self.addChild(gameInfo.gameOverLabel)
        self.addChild(gameInfo.cashLabel)
        self.addChild(gameInfo.healthIndicator)
        self.addChild(gameInfo.speedometer)
        self.addChild(gameInfo.speedometerBG)
        self.addChild(gameInfo.powerUp)
        self.addChild(gameInfo.reverseLabel)
        self.addChild(gameInfo.fuelLabel)
        self.addChild(gameInfo.wantedLevelLabel)
        self.addChild(gameInfo.tapToStartLabel)
        self.addChild(gameInfo.instructionsLabel)
        addChild(gameInfo.restart)
        
        context?.stateMachine?.enter(CTStartMenuState.self)
    }
        
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        
        // for collision
        physicsWorld.contactDelegate = self
        
        prepareGameContext()
        prepareStartNodes()
        
//        context.stateMachine?.enter(CTGamePlayState.self)
        context.stateMachine?.enter(CTStartMenuState.self)
        
//        gameInfo.isPaused = true
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        
        context?.stateMachine?.update(deltaTime: currentTime)
        
        gameInfo.updateScore(phoneRuntime: currentTime)
        gameInfo.updateFuelUI()
        
//        let playerNode = playerCarEntity?.carNode
        let velocity = playerCarEntity?.carNode.physicsBody?.velocity ?? CGVector(dx: 0.0, dy: 0.0)
        self.playerSpeed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        
//        let forwardDirection = CGVector(dx: cos((playerCarEntity?.carNode.zRotation)!), dy: sin((playerCarEntity?.carNode.zRotation)!))
//        let forwardSpeed = velocity.dx * forwardDirection.dx + velocity.dy * forwardDirection.dy
//        gameInfo.playerForwardSpeed = forwardSpeed
//        print(forwardSpeed)
        
//        print(self.playerSpeed)
        if (self.playerSpeed < 60.0 && !gameInfo.gameOver && !gameInfo.isPaused)
        {
            gameInfo.setReverseIsHiddenVisibility(val: false)
        }
        else
        {
            gameInfo.setReverseIsHiddenVisibility(val: true)
        }
        
        if !gameInfo.isPaused
        {
            gameInfo.consumeFuel()
        }
        
        // The UI components are moved by adding/subtracting a fraction of the screen width/height.
        // Increase the modifier value to move closer to center of screen.
        let scoreAndTimeXModifier: CGFloat = 25.0
        let scoreAndTimeYModifier: CGFloat = 8.0
        
        let healthXModifier: CGFloat = 10
        let healthYModifier: CGFloat = 10
        
        let startMenuTextYModifier: CGFloat = 25.0
        
        let speedometerYModifier: CGFloat = 9
        
        // Text UI Components
        gameInfo.scoreLabel.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / scoreAndTimeXModifier), y: cameraNode!.position.y + (layoutInfo.screenSize.height / scoreAndTimeYModifier))
        gameInfo.timeLabel.position = CGPoint(x: cameraNode!.position.x - (layoutInfo.screenSize.width / scoreAndTimeXModifier), y: cameraNode!.position.y + (layoutInfo.screenSize.height / scoreAndTimeYModifier))
        gameInfo.gameOverLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / 14))
        gameInfo.cashLabel.position = CGPoint(x: cameraNode!.position.x - (layoutInfo.screenSize.width / healthXModifier), y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier))
        
        gameInfo.reverseLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / 18))
        gameInfo.fuelLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / 18))
        gameInfo.wantedLevelLabel.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / scoreAndTimeXModifier), y: cameraNode!.position.y + (layoutInfo.screenSize.height / scoreAndTimeYModifier))
        
        gameInfo.tapToStartLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / startMenuTextYModifier))
        gameInfo.instructionsLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / startMenuTextYModifier))
        
        gameInfo.healthLabel.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / healthXModifier), y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier) )
        gameInfo.setHealthLabel(value: gameInfo.playerHealth)
        // Non-text UI components
        gameInfo.healthIndicator.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / healthXModifier), y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier))
        gameInfo.healthIndicator.alpha = 0.5
        

        gameInfo.speedometer.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / speedometerYModifier))
        gameInfo.speedometerBG.position = CGPoint(x: cameraNode!.position.x + gameInfo.updateSpeed(speed: speed), y: cameraNode!.position.y - (layoutInfo.screenSize.height / speedometerYModifier))
        
        gameInfo.powerUp.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier))
        
        gameInfo.restart.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y)
        
        // ai section
        updateCopComponents()
        updateCopCarComponents()
        updatePedCarComponents()
        updatePlayerCarComponents()
        
    }
    
    func updatePlayerCarComponents() {
        var points: [CGPoint] = []
        
        for copCarEntity in copTruckEntities{
            points.append(copCarEntity.carNode.position)
        }
        
        for copCarEntity in copCarEntities{
            points.append(copCarEntity.carNode.position)
        }
       
        for copCarEntity in copTankEntities{
            points.append(copCarEntity.carNode.position)
        }
        
        if let playerCarEntity {
            let minPoint = points.min(by: {
                playerCarEntity.carNode.calculateSquareDistance(pointA: $0, pointB: playerCarEntity.carNode.position) <
                playerCarEntity.carNode.calculateSquareDistance(pointA: $1, pointB: playerCarEntity.carNode.position)
            })
            if let shootingComponenet = playerCarEntity.component(ofType: CTShootingComponent.self) {
                shootingComponenet.interval = gameInfo.gunShootInterval
                shootingComponenet.shoot(target: minPoint ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let arrowFollowComponent = playerCarEntity.component(ofType: CTPickupFollowArrow.self) {
                arrowFollowComponent.gameScene = self
                arrowFollowComponent.setTarget(targetPoint: gameInfo.fuelPosition)
            }
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
    
    func updateCopComponents(){
        for copEntity in copEntities{
            if let trackingComponent = copEntity.component(ofType: CTCopWalkingComponent.self) {
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
                trackingComponent.avoidObstacles()
            }
           if let drivingComponent = copEntity.component(ofType: CTDrivingComponent.self) {
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
            
             // if the health of enemy is very less
            if copCarEntity.carNode.health <= 0.0 {
                 if let healthComponent = copCarEntity.component(ofType: CTHealthComponent.self) {
                     healthComponent.applyDeath()
                 }
                if let index =  copCarEntities.firstIndex(of: copCarEntity) {
                    copCarEntities.remove(at: index)
                }
                gameInfo.numberOfCops -= 1
                continue;
            }
            
            func checkCopSpeed() -> CGFloat
            {
                let copSpeed = sqrt(pow((copCarEntity.carNode.physicsBody?.velocity.dx)!, 2) + pow((copCarEntity.carNode.physicsBody?.velocity.dy)!, 2))
                return copSpeed
            }

            // Giving cops chance to catch up to player
            if (copCarEntity.carNode.physicsBody!.mass >= 50 && distanceWithPlayer < 1000.0 && checkCopSpeed() > 110)
            {
                copCarEntity.carNode.physicsBody?.mass -= 10
            }
            else if (copCarEntity.carNode.physicsBody!.mass < 50)
            {
                copCarEntity.carNode.physicsBody?.mass = 50.0
            }
            
            
            if let trackingComponent = copCarEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copCarEntity.component(ofType: CTDrivingComponent.self) {
                    drivingComponent.drive(driveDir: .forward)
            }
            
            if let shootingComponent = copCarEntity.component(ofType: CTShootingComponent.self) {
                shootingComponent.shoot(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            
            if let arrestngComponent = copCarEntity.component(ofType: CTArrestingCopComponent.self){
                arrestngComponent.update()
            }
            
        }
        for copTruckEntity in copTruckEntities{
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(pointA: copTruckEntity.carNode.position, pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)) ?? 0
            
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copTruckEntity.carNode.removeFromParent()
                if let index =  copTruckEntities.firstIndex(of: copTruckEntity) {
                    copTruckEntities.remove(at: index)
                }
                gameInfo.numberOfCops -= 1
                continue;
            }
            
            // if the health of enemy is very less
            if copTruckEntity.carNode.health <= 0.0 {
                 if let healthComponent = copTruckEntity.component(ofType: CTHealthComponent.self) {
                     healthComponent.applyDeath()
                 }
                if let index =  copTruckEntities.firstIndex(of: copTruckEntity) {
                    copTruckEntities.remove(at: index)
                }
                gameInfo.numberOfCops -= 1
                continue;
            }
            
            if let trackingComponent = copTruckEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copTruckEntity.component(ofType: CTDrivingComponent.self) {
                    drivingComponent.drive(driveDir: .forward)
            }
            
            if let shootingComponent = copTruckEntity.component(ofType: CTShootingComponent.self) {
                shootingComponent.shoot(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let arrestngComponent = copTruckEntity.component(ofType: CTArrestingCopComponent.self){
                arrestngComponent.update()
            }
            
        }
        
        for copTankEntity in copTankEntities{
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(pointA: copTankEntity.carNode.position, pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)) ?? 0
            
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copTankEntity.carNode.removeFromParent()
                if let index =  copTankEntities.firstIndex(of: copTankEntity) {
                    copTruckEntities.remove(at: index)
                }
                gameInfo.numberOfCops -= 1
                continue;
            }
            
            // if the health of enemy is very less
            if copTankEntity.carNode.health <= 0.0 {
                 if let healthComponent = copTankEntity.component(ofType: CTHealthComponent.self) {
                     healthComponent.applyDeath()
                 }
                if let index =  copTankEntities.firstIndex(of: copTankEntity) {
                    copTruckEntities.remove(at: index)
                }
                gameInfo.numberOfCops -= 1
                continue;
            }
            
            if let trackingComponent = copTankEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copTankEntity.component(ofType: CTDrivingComponent.self) {
                    drivingComponent.drive(driveDir: .forward)
            }
            
            if let shootingComponent = copTankEntity.component(ofType: CTShootingComponent.self) {
                shootingComponent.shoot(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            
        }
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
        
        // set player car from scene
//        let playerCarNode = CTCarNode(imageNamed: "red", size: (context.layoutInfo.playerCarSize) )
      
        // spawns ped cars
        pedCarSpawner = self.childNode(withName: "PedAI") as? CTPedAINode
        pedCarSpawner?.context = context
        
        // spawns cop cars
        copCarSpawner = self.childNode(withName: "CopAI") as? CTCopAINode
        copCarSpawner?.context = context
        
        // obstacle spawner
        let obstacleSpawner = self.childNode(withName: "dynamicObstacle") as? CTDynamicObstacleNode
        obstacleSpawner?.context = context
        obstacleSpawner?.assignNode(offset: CGPoint(x: 0.0, y: 0.0))
        
        // camera node
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        addChild(cameraNode)
        self.cameraNode = cameraNode
        camera = self.cameraNode
        
        let zoomInAction = SKAction.scale(to: 0.35, duration: 0.2)
        // debug camera
//        let zoomInAction = SKAction.scale(to: 1, duration: 0.2)
        cameraNode.run(zoomInAction)
        
        
        
    }
    
    func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        return start + (end - start) * t
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let state = context?.stateMachine?.currentState as? CTGamePlayState else {
//            print("touched")
            // Tap to play logic
            if ((gameInfo.instructionsLabel.isHidden == false) && (gameInfo.isPaused == true))
            {
    //            gameInfo.isPaused = false
                context?.stateMachine?.enter(CTGamePlayState.self)
//                print("trying to play")
            }
            pedCarSpawner?.populateAI()
            copCarSpawner?.populateAI()
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
        
        // player collision
        // non-damage collision
        if collision == (CTPhysicsCategory.car | CTPhysicsCategory.cash) ||
            collision == (CTPhysicsCategory.car | CTPhysicsCategory.fuel){
            
            let colliderNode = (contact.bodyA.categoryBitMask != CTPhysicsCategory.car) ? contact.bodyA.node : contact.bodyB.node
            let pickupNode = (contact.bodyA.categoryBitMask == CTPhysicsCategory.car) ? contact.bodyB.node : contact.bodyA.node
            
           
            colliderNode?.removeFromParent()
            if categoryA == CTPhysicsCategory.cash || categoryB == CTPhysicsCategory.cash {
                // add cash if car hits a powerup and remove cash from total
                gameInfo.cashCollected = gameInfo.cashCollected + 1
                gameInfo.isCashPickedUp = true
                
                // randomly applies one powerup if we collect 3 powerup
                if(gameInfo.cashCollected == 1) {
                    activatePowerUp()
    //                giveShootingAbility()
                    gameInfo.cashCollected = 0
                }
                     
            }
            
            if categoryA == CTPhysicsCategory.fuel || categoryB == CTPhysicsCategory.fuel{
                gameInfo.refillFuel(amount: 50.0)
                gameInfo.isFuelPickedUp = true
            }
           
        }
        
        
        // if bullet hits anything remove it from the scene
        if categoryB == CTPhysicsCategory.copBullet || categoryA == CTPhysicsCategory.copBullet {
            print("bullet hit something")
            let bullet = (contact.bodyA.categoryBitMask == CTPhysicsCategory.copBullet) ? contact.bodyA.node as? CTCopBulletNode : contact.bodyB.node as? CTCopBulletNode
            bullet?.removeFromParent()
        }
        if categoryB == CTPhysicsCategory.playerBullet || categoryA == CTPhysicsCategory.playerBullet {
            print("bullet hit something")
            let bullet = (contact.bodyA.categoryBitMask == CTPhysicsCategory.playerBullet) ? contact.bodyA.node as? CTPlayerBulletNode : contact.bodyB.node as? CTPlayerBulletNode
            bullet?.removeFromParent()
        }
        
        // bullet collision
        if collision == (CTPhysicsCategory.copBullet | CTPhysicsCategory.car) {
//            gameInfo.playerHealth -= 25
            gameInfo.decreasePlayerHealth(amount: 25.0)
            showDamageFlashEffect()
        }
        
        if collision == (CTPhysicsCategory.car | CTPhysicsCategory.copCar) || collision == (CTPhysicsCategory.car | CTPhysicsCategory.copTruck) || collision == (CTPhysicsCategory.car | CTPhysicsCategory.copTank) || collision == (CTPhysicsCategory.car | CTPhysicsCategory.ped)
        {
            showDamageFlashEffect()
        }
        
        // enemy damages
        
        // bullet collision
//        if  collision == (CTPhysicsCategory.playerBullet | CTPhysicsCategory.copCar)  ||
//                collision == (CTPhysicsCategory.playerBullet | CTPhysicsCategory.copTank) ||
//                collision == (CTPhysicsCategory.playerBullet | CTPhysicsCategory.copTruck) {
//            print("enemy hit by bullet")
//
//            let bullet = (contact.bodyA.categoryBitMask == CTPhysicsCategory.playerBullet) ? contact.bodyA.node as? CTPlayerBulletNode : contact.bodyB.node as? CTPlayerBulletNode
//
//            var enemy: EnemyNode? // Replace `EnemyNode` with your base type if applicable
//
//            if contact.bodyA.categoryBitMask == CTPhysicsCategory.copTruck,
//               let truck = contact.bodyA.node as? CTCopTruckNode {
//                enemy = truck
//            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copTruck,
//                      let truck = contact.bodyB.node as? CTCopTruckNode {
//                enemy = truck
//            } else if contact.bodyA.categoryBitMask == CTPhysicsCategory.copCar,
//                      let car = contact.bodyA.node as? CTCopCarNode {
//                enemy = car
//            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copCar,
//                      let car = contact.bodyB.node as? CTCopCarNode {
//                enemy = car
//            }
//
//            // Apply health reduction if an enemy was found
//            if var enemy = enemy {
//                enemy.health -= 10.0
//            }
//
//        }
        
        
        // damage collision
//        if  (categoryA == CTPhysicsCategory.copCar || categoryB == CTPhysicsCategory.copCar) ||
//                (categoryA == CTPhysicsCategory.copTank || categoryB == CTPhysicsCategory.copTank) ||
//                (categoryA == CTPhysicsCategory.copTruck || categoryB == CTPhysicsCategory.copTruck)
//
//        {
//
//            var enemy: EnemyNode? // Replace `EnemyNode` with your base type if applicable
//
//            if contact.bodyA.categoryBitMask == CTPhysicsCategory.copTruck,
//               let truck = contact.bodyA.node as? CTCopTruckNode {
//                enemy = truck
//            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copTruck,
//                      let truck = contact.bodyB.node as? CTCopTruckNode {
//                enemy = truck
//            } else if contact.bodyA.categoryBitMask == CTPhysicsCategory.copCar,
//                      let car = contact.bodyA.node as? CTCopCarNode {
//                enemy = car
//            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copCar,
//                      let car = contact.bodyB.node as? CTCopCarNode {
//                enemy = car
//            }
//
//
//            let colliderNode = (
//                contact.bodyA.categoryBitMask == CTPhysicsCategory.copCar   ||
//                contact.bodyA.categoryBitMask == CTPhysicsCategory.copTank  ||
//                contact.bodyA.categoryBitMask == CTPhysicsCategory.copTruck
//            ) ? contact.bodyB.node : contact.bodyA.node
//
//            let carVelocityMag = pow(enemy?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(enemy?.physicsBody?.velocity.dy ?? 0.0, 2)
//            let colliderVelocityMag:CGFloat = pow(colliderNode?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(colliderNode?.physicsBody?.velocity.dy ?? 0.0, 2)
//
//            // Apply health reduction if an enemy was found
//            if var enemy = enemy {
//                enemy.health -= abs(carVelocityMag - colliderVelocityMag) * 0.00008
//            }
//        }
    }
}

extension CTGameScene{
    
    func activatePowerUp() {
        let sprite = gameInfo.powerUp
//        gameInfo.powerUp.isHidden = false
        
        let showAction = SKAction.run { sprite.isHidden = false }
        let waitAction = SKAction.wait(forDuration: 3.0)
        let hideAction = SKAction.run { sprite.isHidden = true }

        // Sequence of actions
        let sequence = SKAction.sequence([showAction, waitAction, hideAction])
        
        let randomNumber = GKRandomDistribution(lowestValue: 0, highestValue: 9).nextInt()
        switch(randomNumber){
        case 0,1,2:
//            boostHealth()
            destroyCops()
            break;
        case 3,4,5,6:
             increaseSpeed()
            break;
        case 7,8:
            giveShootingAbility()
            break;
        case 9:
            giveMachineGun()
        default:
            break;
        }
//        gameInfo.powerUp.isHidden = true
        run(sequence)
    }
    
//    func boostHealth() {
////        gameInfo.playerHealth = gameInfo.playerHealth + 25
//        gameInfo.increasePlayerHealth(amount: 25)
//        gameInfo.powerUp.texture = SKTexture(imageNamed: "healthBoost")
//        print("boostHealth")
//    }
    
    func destroyCops() {
        gameInfo.powerUp.texture = SKTexture(imageNamed: "damageBoost")
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
        for copCarEntity in copTankEntities{
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            copCarEntity.carNode.run(fadeOutAction) {
                if let index =  self.copTankEntities.firstIndex(of: copCarEntity) {
                    copCarEntity.carNode.removeFromParent()
                    self.copTankEntities.remove(at: index)
                    self.gameInfo.numberOfCops -= 1
                }
            }
            
        }
        for copCarEntity in copTruckEntities{
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            copCarEntity.carNode.run(fadeOutAction) {
                if let index =  self.copTruckEntities.firstIndex(of: copCarEntity) {
                    copCarEntity.carNode.removeFromParent()
                    self.copTruckEntities.remove(at: index)
                    self.gameInfo.numberOfCops -= 1
                }
            }
            
        }
        print("destroyCops")
    }
    
    func increaseSpeed() {
        gameInfo.playerSpeed = gameInfo.playerSpeed + 400
        gameInfo.powerUp.texture = SKTexture(imageNamed: "speedBoost")
        print("increase Speed")
    }
    
    func giveShootingAbility() {
        gameInfo.powerUp.texture = SKTexture(imageNamed: "damageBoost")
        if let playerCarEntity {
            playerCarEntity.addComponent(CTShootingComponent(carNode: playerCarEntity.carNode))
        }
        print("shootingAbility")
    }
    
    func giveMachineGun() {
        gameInfo.powerUp.texture = SKTexture(imageNamed: "damageBoost")
        if ((playerCarEntity?.component(ofType: CTShootingComponent.self)) != nil) {
            gameInfo.gunShootInterval = 4_000_000
            print("machine gun given")
        }else {
            // if the player doesnt't have a gun then give another powerup
            activatePowerUp()
        }
    }
    
    func showDamageFlashEffect() {
        // Create a full-screen red overlay
        let flashNode = SKSpriteNode(color: .red, size: self.size)
//        flashNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        flashNode.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y)
        flashNode.zPosition = 1000 // Ensure it covers everything
        flashNode.alpha = 0.1 // Start with semi-transparency
        addChild(flashNode)
        
        // Create actions for the fade-out effect
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        
        // Run the sequence
        flashNode.run(sequence)
    }

}
