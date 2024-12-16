//  CTGameScene.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/26/24.
//

import SpriteKit
import GameplayKit
import AVFoundation
import UIKit

class CTGameScene: SKScene {
    weak var context: CTGameContext?
    
    var bgMusicPlayer: AVAudioPlayer?
    let outlineShader = SKShader(fileNamed: "outlineShader.fsh")
    
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
    
    var powerupPickupSound: AVAudioPlayer?
    var fuelPickupSound: AVAudioPlayer?
    
    let GAME_SPEED_INCREASE_RATE = 0.01
    
    var gameHasNotStarted = true
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        self.gameInfo = CTGameInfo()
        self.layoutInfo = CTLayoutInfo(screenSize: UIScreen.main.bounds.size)
        super.init(coder: aDecoder)
        self.view?.isMultipleTouchEnabled = true
//        self.addChild(gameInfo.scoreLabel)
        self.addChild(gameInfo.timeLabel)
//        self.addChild(gameInfo.healthLabel)
        self.addChild(gameInfo.gameOverLabel)
//        self.addChild(gameInfo.cashLabel)
//        self.addChild(gameInfo.healthIndicator)
//        self.addChild(gameInfo.speedometer)
//        self.addChild(gameInfo.speedometerBG)
        self.addChild(gameInfo.powerUp)
        self.addChild(gameInfo.reverseLabel)
        self.addChild(gameInfo.fuelLabel)
        self.addChild(gameInfo.wantedLevelLabel)
        self.addChild(gameInfo.tapToStartLabel)
        self.addChild(gameInfo.instructionsLabel)
        self.addChild(gameInfo.powerupLabel)
        self.addChild(gameInfo.powerupHintLabel)
        self.addChild(gameInfo.restartButton)
        self.addChild(gameInfo.logo)
        self.addChild(gameInfo.instructions)
        self.addChild(gameInfo.backgroundNode)
//        self.addChild(gameInfo.blurryOverlay)
        
//        outlineShader.uniforms = [
//            SKUniform(name: "outlineWidth", float: 0.02),
//            SKUniform(name: "outlineColor", vectorFloat4: SIMD4<Float>(0, 0, 0, 1))
//        ]
        
        context?.stateMachine?.enter(CTStartMenuState.self)
    }
    
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        
        
        if let musicURL = Bundle.main.url(forResource: "track1", withExtension: "mp3") {
            do {
                bgMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                bgMusicPlayer?.volume = 0.4
                bgMusicPlayer?.numberOfLoops = -1 // Infinite loop
                bgMusicPlayer?.play()
            } catch {
                print("Error loading background music: \(error)")
            }
        }
        
        if let powerupSoundURL = Bundle.main.url(forResource: "powerup_pickup", withExtension: "mp3") {
             do {
                 powerupPickupSound = try AVAudioPlayer(contentsOf: powerupSoundURL)
                 powerupPickupSound?.volume = 0.5
             } catch {
                 print("Error loading cash pickup sound: \(error)")
             }
         }
         
         if let fuelSoundURL = Bundle.main.url(forResource: "fuel_pickup", withExtension: "mp3") {
             do {
                 fuelPickupSound = try AVAudioPlayer(contentsOf: fuelSoundURL)
                 fuelPickupSound?.volume = 0.5
             } catch {
                 print("Error loading fuel pickup sound: \(error)")
             }
         }
        
        if gameHasNotStarted {
            // for collision
            physicsWorld.contactDelegate = self
            
//            triggerHapticFeedback(style: .light, intensity: 0.75)
            
            prepareGameContext()
            prepareStartNodes()
            
            context.stateMachine?.enter(CTStartMenuState.self)
            
            gameHasNotStarted = false
                 
        }
       
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        context?.stateMachine?.update(deltaTime: currentTime)
        
        
        // don't let the number of cops be less than 0
        if gameInfo.numberOfCops < 0 {
            gameInfo.numberOfCops = 0
        }
        
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
//        gameInfo.scoreLabel.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / scoreAndTimeXModifier), y: cameraNode!.position.y + (layoutInfo.screenSize.height / scoreAndTimeYModifier))
        gameInfo.timeLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / scoreAndTimeYModifier))
        gameInfo.gameOverLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / 16))
//        gameInfo.cashLabel.position = CGPoint(x: cameraNode!.position.x - (layoutInfo.screenSize.width / healthXModifier), y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier))
        
        gameInfo.reverseLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / 18))
        gameInfo.fuelLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / 12))
        gameInfo.wantedLevelLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + ((layoutInfo.screenSize.height / scoreAndTimeYModifier) * 0.85))
        
        gameInfo.tapToStartLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - ((layoutInfo.screenSize.height / startMenuTextYModifier) / 0.475))
        gameInfo.instructionsLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y/* + (layoutInfo.screenSize.height / startMenuTextYModifier) * 1*/)
        
        gameInfo.powerupLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / 8))
        gameInfo.powerupHintLabel.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / 6))
        
//        gameInfo.healthLabel.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / healthXModifier), y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier) )
//        gameInfo.setHealthLabel(value: gameInfo.playerHealth)
//        // Non-text UI components
//        gameInfo.healthIndicator.position = CGPoint(x: cameraNode!.position.x + (layoutInfo.screenSize.width / healthXModifier), y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier))
//        gameInfo.healthIndicator.alpha = 0.5
        
        
//        gameInfo.speedometer.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / speedometerYModifier))
//        gameInfo.speedometerBG.position = CGPoint(x: cameraNode!.position.x + gameInfo.updateSpeed(speed: speed), y: cameraNode!.position.y - (layoutInfo.screenSize.height / speedometerYModifier))
        
        gameInfo.powerUp.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / healthYModifier))
        
        gameInfo.restartButton.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y)
        
        gameInfo.logo.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y + (layoutInfo.screenSize.height / startMenuTextYModifier) * 1.2)
        gameInfo.instructions.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y - (layoutInfo.screenSize.height / startMenuTextYModifier))
        
        gameInfo.backgroundNode.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y)
//        gameInfo.blurryOverlay.position = CGPoint(x: cameraNode!.position.x, y: cameraNode!.position.y)
        
        updatePedCarComponents()
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
        pedCarSpawner?.populateAI()
        
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
        
        //Two-finger touch
        let activeTouches = event?.allTouches?.filter { $0.phase == .began || $0.phase == .stationary }
        
        if let state = context?.stateMachine?.currentState as? CTStartMenuState {
//            state.handleTouchStart(touches)
            state.handleTouchStart(activeTouches ?? touches)
        }
        if let state = context?.stateMachine?.currentState as? CTGamePlayState {
//            state.handleTouchStart(touches)
            state.handleTouchStart(activeTouches ?? touches)
        }
        
//        if activeTouches?.count == 2 {
//            handleTwoFingerTouch()
//        }
        
    }
    
//    func handleTwoFingerTouch() {
//        print("Two-finger touch detected!")
//        // Trigger your game event here
//    }
    
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

        // Non-damage collisions
        if collision == (CTPhysicsCategory.car | CTPhysicsCategory.cash) ||
            collision == (CTPhysicsCategory.car | CTPhysicsCategory.fuel) {
            
            // Haptic feedback for non-damage/pick-up collision
            triggerHapticFeedback(style: .soft, intensity: 0.75)
            
            let colliderNode = (contact.bodyA.categoryBitMask != CTPhysicsCategory.car) ? contact.bodyA.node : contact.bodyB.node
            _ = (contact.bodyA.categoryBitMask == CTPhysicsCategory.car) ? contact.bodyB.node : contact.bodyA.node
            
            colliderNode?.removeFromParent()
            if categoryA == CTPhysicsCategory.cash || categoryB == CTPhysicsCategory.cash {
                gameInfo.cashCollected = gameInfo.cashCollected + 1
                gameInfo.isCashPickedUp = true
                powerupPickupSound?.play()
                
                if gameInfo.cashCollected == 1 {
                    activatePowerUp()
                    gameInfo.cashCollected = 0
                }
            }
            
            if categoryA == CTPhysicsCategory.fuel || categoryB == CTPhysicsCategory.fuel {
                fuelPickupSound?.play()
                gameInfo.refillFuel(amount: 50.0)
                gameInfo.isFuelPickedUp = true
            }
        }

        // Bullet collisions
        if categoryB == CTPhysicsCategory.copBullet || categoryA == CTPhysicsCategory.copBullet {
            let bullet = (contact.bodyA.categoryBitMask == CTPhysicsCategory.copBullet) ? contact.bodyA.node as? CTCopBulletNode : contact.bodyB.node as? CTCopBulletNode
            bullet?.removeFromParent()
            triggerHapticFeedback(style: .rigid, intensity: 1.0)
        }

        if categoryB == CTPhysicsCategory.playerBullet || categoryA == CTPhysicsCategory.playerBullet {
            let bullet = (contact.bodyA.categoryBitMask == CTPhysicsCategory.playerBullet) ? contact.bodyA.node as? CTPlayerBulletNode : contact.bodyB.node as? CTPlayerBulletNode
            bullet?.removeFromParent()
        }

        // Car and cop collision
        if collision == (CTPhysicsCategory.car | CTPhysicsCategory.copCar) ||
           collision == (CTPhysicsCategory.car | CTPhysicsCategory.copTruck) ||
           collision == (CTPhysicsCategory.car | CTPhysicsCategory.copTank) ||
           collision == (CTPhysicsCategory.car | CTPhysicsCategory.ped) {
            showDamageFlashEffect()
//            triggerHapticFeedback(style: .light, intensity: 0.1)
        }

        // Player bullet hitting enemy
        if collision == (CTPhysicsCategory.playerBullet | CTPhysicsCategory.copCar) ||
           collision == (CTPhysicsCategory.playerBullet | CTPhysicsCategory.copTruck) ||
           collision == (CTPhysicsCategory.playerBullet | CTPhysicsCategory.copTank) {
            print("enemy hit by bullet")
            
            _ = (contact.bodyA.categoryBitMask == CTPhysicsCategory.playerBullet) ? contact.bodyA.node as? CTPlayerBulletNode : contact.bodyB.node as? CTPlayerBulletNode
            
            var enemy: EnemyNode?
            if contact.bodyA.categoryBitMask == CTPhysicsCategory.copTruck,
               let truck = contact.bodyA.node as? CTCopTruckNode {
                enemy = truck
            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copTruck,
                      let truck = contact.bodyB.node as? CTCopTruckNode {
                enemy = truck
            } else if contact.bodyA.categoryBitMask == CTPhysicsCategory.copCar,
                      let car = contact.bodyA.node as? CTCopCarNode {
                enemy = car
            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copCar,
                      let car = contact.bodyB.node as? CTCopCarNode {
                enemy = car
            }
            
            if let enemy = enemy {
                enemy.health -= 10.0
//                print(enemy.health)
            }
        }
        
        
//         damage collision only for enemy to enemy damage
        if  (categoryA == CTPhysicsCategory.copCar || categoryB == CTPhysicsCategory.copCar) ||
                (categoryA == CTPhysicsCategory.copTank || categoryB == CTPhysicsCategory.copTank) ||
                (categoryA == CTPhysicsCategory.copTruck || categoryB == CTPhysicsCategory.copTruck)

        {

            var enemy: EnemyNode? // Replace EnemyNode with your base type if applicable

            if contact.bodyA.categoryBitMask == CTPhysicsCategory.copTruck,
               let truck = contact.bodyA.node as? CTCopTruckNode {
                enemy = truck
            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copTruck,
                      let truck = contact.bodyB.node as? CTCopTruckNode {
                enemy = truck
            } else if contact.bodyA.categoryBitMask == CTPhysicsCategory.copCar,
                      let car = contact.bodyA.node as? CTCopCarNode {
                enemy = car
            } else if contact.bodyB.categoryBitMask == CTPhysicsCategory.copCar,
                      let car = contact.bodyB.node as? CTCopCarNode {
                enemy = car
            }


            let colliderNode = (
                contact.bodyA.categoryBitMask == CTPhysicsCategory.copCar   ||
                contact.bodyA.categoryBitMask == CTPhysicsCategory.copTank  ||
                contact.bodyA.categoryBitMask == CTPhysicsCategory.copTruck
            ) ? contact.bodyB.node : contact.bodyA.node

            let carVelocityMag = pow(enemy?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(enemy?.physicsBody?.velocity.dy ?? 0.0, 2)
            let colliderVelocityMag:CGFloat = pow(colliderNode?.physicsBody?.velocity.dx ?? 0.0, 2) + pow(colliderNode?.physicsBody?.velocity.dy ?? 0.0, 2)

            // Apply health reduction if an enemy was found
            if let enemy = enemy {
                enemy.health -= abs(carVelocityMag - colliderVelocityMag) * 0.0001
//                print(enemy.health)
            }
        }
        
    }
    
    // Trigger haptics for non-damage collisions
    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
        UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: 1.0)
        print("haptics active")
    }
}

extension CTGameScene{
    
    func activatePowerUp() {
//        let sprite = gameInfo.powerUp
//        let pUpLabel = gameInfo.powerupLabel
//        let pUpHintLabel = gameInfo.powerupHintLabel
//        gameInfo.powerUp.isHidden = false
        
//        let showAction = SKAction.run { sprite.isHidden = false; pUpLabel.isHidden = false }
//        let waitAction = SKAction.wait(forDuration: 5.0)
//        let hideAction = SKAction.run { sprite.isHidden = true; pUpLabel.isHidden = true }
//
//        // Sequence of actions
//        let sequence = SKAction.sequence([showAction, waitAction, hideAction])
        
        let randomNumber = GKRandomDistribution(lowestValue: 0, highestValue: 9).nextInt()
        switch(randomNumber){
        case 0,1,2:
            destroyCops(gameRestart: false)
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
//        run(sequence)
    }
    
//    func boostHealth() {
////        gameInfo.playerHealth = gameInfo.playerHealth + 25
//        gameInfo.increasePlayerHealth(amount: 25)
//        gameInfo.powerUp.texture = SKTexture(imageNamed: "healthBoost")
//        print("boostHealth")
//    }
    
    func destroyCops(gameRestart: Bool) {
        if !gameRestart
        {
            gameInfo.powerUp.texture = SKTexture(imageNamed: "damageBoost")
            changePowerupUIText(pUpLabel: "Destroy Nearby Cops", pUpHintText: "Powerup applied automatically.")
        }
        
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
        
        for copEntity in copEntities{
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            copEntity.cop.run(fadeOutAction) {
                if let index =  self.copEntities.firstIndex(of: copEntity) {
                    copEntity.cop.removeFromParent()
                    self.copEntities.remove(at: index)
                }
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0)
        {
            self.hidePowerupUI()
        }
        
        print("destroyCops")
    }
    
    func increaseSpeed() {
        print("increase Speed")
        gameInfo.powerUp.texture = SKTexture(imageNamed: "speedBoost")
        
        changePowerupUIText(pUpLabel: "Speed Boost", pUpHintText: "Powerup applied automatically.")
        
        //TODO: on click:
        
        if let playerCarEntity {
            if let drivingComponent = playerCarEntity.component(ofType: CTDrivingComponent.self){
                drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE * 1.5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0)
        {
            self.hidePowerupUI()
            if let playerCarEntity = self.playerCarEntity {
                if let drivingComponent = playerCarEntity.component(ofType: CTDrivingComponent.self){
                    drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE / 1.5
                }
            }
        }
    }
    
    func giveShootingAbility() {
        gameInfo.powerUp.texture = SKTexture(imageNamed: "damageBoost")
        
        changePowerupUIText(pUpLabel: "Shooting", pUpHintText: "Powerup applied automatically.")
        
        if let playerCarEntity {
            playerCarEntity.addComponent(CTShootingComponent(carNode: playerCarEntity.carNode))
        }
        
        // player gets shooting for 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0)
        {
            self.hidePowerupUI()
            if let playerCarEntity = self.playerCarEntity {
                playerCarEntity.removeComponent(ofType: CTShootingComponent.self)
            }
        }
        
        print("shootingAbility")
    }
    
    func giveMachineGun() {
        if ((playerCarEntity?.component(ofType: CTShootingComponent.self)) != nil) {
            gameInfo.powerUp.texture = SKTexture(imageNamed: "damageBoost")
            changePowerupUIText(pUpLabel: "Machine Gun", pUpHintText: "Powerup applied automatically.")
            
            gameInfo.gunShootInterval = 4_000_000
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0)
            {
                self.hidePowerupUI()
            }
            
            print("machine gun given")
        }else {
            // if the player doesnt't have a gun then give another powerup
            activatePowerUp()
        }
    }
    
    func changePowerupUIText(pUpLabel: String, pUpHintText: String)
    {
        gameInfo.powerUp.isHidden = false
        gameInfo.powerupLabel.text = pUpLabel
        gameInfo.powerupLabel.isHidden = false
        gameInfo.powerupHintLabel.text = pUpHintText
        gameInfo.powerupHintLabel.isHidden = false
    }
    
    func hidePowerupUI()
    {
        gameInfo.powerUp.isHidden = true
        gameInfo.powerupLabel.isHidden = true
        gameInfo.powerupHintLabel.isHidden = true
    }
    
    func showDamageFlashEffect() {
        // Create a full-screen red overlay
        let flashNode = SKSpriteNode(color: .red, size: self.size)
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
