//
//  CTGameIdelState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import GameplayKit
import AVFAudio

class CTGamePlayState: GKState {
    weak var scene: CTGameScene?
    weak var context: CTGameContext?
    
    var playerAlreadySpawned = false
    var moveDirection: CGFloat = 0.0
    var isTouchingSingle: Bool = false
    var isTouchingDouble: Bool = false
    var touchLocations: Array<CGPoint> = []
    var driveDir = CTDrivingComponent.driveDir.forward
    
    var startTime = 0.0
    var initialTimeSet = false
    
    var firstWaveSet = false
    var secondWaveSet = false
    var thirdWaveSet = false
    var fourthWaveSet = false
    
    var scaleEffectSet = false
    var time = 0.0
    
    var arrestStartTime = 0.0
    var arrestTimer = 0.0
    var hasStartedArrest = false
    
    var copStarIncreaseSound: AVAudioPlayer?
   
    init(scene: CTGameScene, context: CTGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter play state")
        
        scene?.gameInfo.setIsPaused(val: false)
        
        moveDirection = 0.0
        isTouchingSingle = false
        isTouchingDouble = false
        touchLocations = []
        driveDir = CTDrivingComponent.driveDir.forward
        
        startTime = 0.0
        initialTimeSet = false
        
        firstWaveSet = false
        secondWaveSet = false
        thirdWaveSet = false
        fourthWaveSet = false
        
        scaleEffectSet = false
        time = 0.0
        
        arrestStartTime = 0.0
        arrestTimer = 0.0
        hasStartedArrest = false
       
        
        scene?.copCarSpawner?.populateAI()
        if !playerAlreadySpawned{
            spawnPlayer()
            playerAlreadySpawned = true
        }
        
        if let copStarIncreaseURL = Bundle.main.url(forResource: "CT_copSirenShortened", withExtension: "mp3") {
            do {
                copStarIncreaseSound = try AVAudioPlayer(contentsOf: copStarIncreaseURL)
                copStarIncreaseSound?.volume = 0.5
            } catch {
                print("Error loading background music: \(error)")
            }
        }
   }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let scene else { return }
        guard let context else { return }
        
        if(scene.gameInfo.gameOver){
            context.stateMachine?.enter(CTGameOverState.self)
            
            copStarIncreaseSound?.stop()
            
            return
        }
        
        time = seconds
        if !initialTimeSet {
            startTime = seconds
            initialTimeSet = true
        }
        
        let elapsedTime = seconds - startTime
        setGameWaveModeParams(elapsedTime: elapsedTime)
       
        handleCameraMovement()
        handleFuelSpawn()
        handleCashSpawn()
        
        if(self.touchLocations != []){
            if(isTouchingDouble){
                
            }
            else if(isTouchingSingle){
                self.moveDirection = self.touchLocations[0].x < scene.frame.midX ? -1.0 : 1.0
            }
        }
         // components
        
        if let drivingComponent = scene.playerCarEntity?.component(ofType: CTDrivingComponent.self){
            drivingComponent.drive(driveDir: self.driveDir)
            drivingComponent.MOVE_FORCE = scene.gameInfo.playerSpeed
        }
        
        if let steerComponent = scene.playerCarEntity?.component(ofType: CTSteeringComponent.self){
            steerComponent.steer(moveDirection: self.moveDirection)
        }
        
        
        // this part of the code arrests player if they are stationary for more than 10 seconds
        if scene.playerSpeed < 3.0 && !hasStartedArrest{
            hasStartedArrest = true
            arrestStartTime = seconds
            
        } else if scene.playerSpeed > 3.0 {
            hasStartedArrest = false
        }
        
        if hasStartedArrest {
           arrestTimer = seconds - arrestStartTime
            if arrestTimer > 10.0 && scene.playerSpeed < 3.0{
                scene.gameInfo.gameOver = true
                scene.gameInfo.setGameOver()
            }
        }
        
        
        
        // ai
        updateCopTankComponents()
        updateCopTruckComponents()
        updateCopCarComponents()
        updateCopComponents()
        
        // player
        updatePlayerCarComponents()
        
    }
    
    
    func updatePlayerCarComponents() {
        
        guard let gameScene = scene else { return }
        guard let playerCarEntity = gameScene.playerCarEntity else { return }

        if let shootingComponenet = playerCarEntity.component(ofType: CTShootingComponent.self) {
            
            var points: [CGPoint] = []
            
            for copCarEntity in gameScene.copTruckEntities{
                points.append(copCarEntity.carNode.position)
            }
            
            for copCarEntity in gameScene.copCarEntities{
                points.append(copCarEntity.carNode.position)
            }
            
            for copCarEntity in gameScene.copTankEntities{
                points.append(copCarEntity.carNode.position)
            }
            
            let minPoint = points.min(by: {
                playerCarEntity.carNode.calculateSquareDistance(pointA: $0, pointB: playerCarEntity.carNode.position) <
                    playerCarEntity.carNode.calculateSquareDistance(pointA: $1, pointB: playerCarEntity.carNode.position)
            })
            
            shootingComponenet.interval = gameScene.gameInfo.gunShootInterval
            shootingComponenet.shoot(target: minPoint ?? CGPoint(x: 0.0, y: 0.0))
        }
        if let arrowFollowComponent = playerCarEntity.component(ofType: CTPickupFollowArrow.self) {
            arrowFollowComponent.gameScene = gameScene
            arrowFollowComponent.setTarget(targetPoint: gameScene.gameInfo.fuelPosition)
        }
    }

    
    func updateCopComponents(){
        
        guard let gameScene = scene else { return }
        let playerCarEntity = gameScene.playerCarEntity
        
        for copEntity in gameScene.copEntities{
            if let trackingComponent = copEntity.component(ofType: CTCopWalkingComponent.self) {
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
                trackingComponent.avoidObstacles()
            }
            if let drivingComponent = copEntity.component(ofType: CTDrivingComponent.self) {
                drivingComponent.drive(driveDir: .forward)
            }
        }
    }
    
    
    func updateCopCarComponents() {
        guard let gameScene = scene else { return }
        var copCarEntities = gameScene.copCarEntities
        let playerCarEntity = gameScene.playerCarEntity
        var gameInfo = gameScene.gameInfo

        // Track entities already removed
        var entitiesToRemove: Set<CTCopCarEntity> = []

        for copCarEntity in copCarEntities {
            if entitiesToRemove.contains(copCarEntity) {
                continue // Skip already marked entities
            }

            // Calculate distance with player
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(
                pointA: copCarEntity.carNode.position,
                pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)
            ) ?? 0

            // Check despawn distance
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copCarEntity.carNode.removeFromParent()
                entitiesToRemove.insert(copCarEntity)
                continue
            }

            // Check health
            if copCarEntity.carNode.health <= 0.0 {
                if let healthComponent = copCarEntity.component(ofType: CTHealthComponent.self) {
                    healthComponent.applyDeath()
                }
                entitiesToRemove.insert(copCarEntity)
                continue
            }

            // Adjust speed based on mass and distance
            func checkCopSpeed() -> CGFloat {
                let velocity = copCarEntity.carNode.physicsBody?.velocity ?? CGVector.zero
                return sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
            }

            if let physicsBody = copCarEntity.carNode.physicsBody {
                if physicsBody.mass >= 50 && distanceWithPlayer < 1000.0 && checkCopSpeed() > 110 {
                    physicsBody.mass -= 10
                } else if physicsBody.mass < 50 {
                    physicsBody.mass = 50.0
                }
            }

            // Update components
            if let trackingComponent = copCarEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copCarEntity.component(ofType: CTDrivingComponent.self) {
                drivingComponent.drive(driveDir: .forward)
                drivingComponent.MOVE_FORCE = gameScene.gameInfo.copCarSpeed
            }
            if let shootingComponent = copCarEntity.component(ofType: CTShootingComponent.self) {
                shootingComponent.shoot(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let arrestingComponent = copCarEntity.component(ofType: CTArrestingCopComponent.self) {
                arrestingComponent.update()
            }
        }

        // Remove marked entities after iteration
        gameInfo.numberOfCops -= entitiesToRemove.count
        gameScene.copCarEntities.removeAll { entitiesToRemove.contains($0) }
    }

    
    
    func updateCopTruckComponents() {
        guard let gameScene = scene else { return }
        var copTruckEntities = gameScene.copTruckEntities
        let playerCarEntity = gameScene.playerCarEntity
        var gameInfo = gameScene.gameInfo

        // Track entities already removed
        var entitiesToRemove: Set<CTCopTruckEntity> = []

        for copTruckEntity in copTruckEntities {
            if entitiesToRemove.contains(copTruckEntity) {
                continue // Skip already marked entities
            }

            // Calculate distance with player
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(
                pointA: copTruckEntity.carNode.position,
                pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)
            ) ?? 0

            // Check despawn distance
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copTruckEntity.carNode.removeFromParent()
                entitiesToRemove.insert(copTruckEntity)
                continue
            }

            // Check health
            if copTruckEntity.carNode.health <= 0.0 {
                if let healthComponent = copTruckEntity.component(ofType: CTHealthComponent.self) {
                    healthComponent.applyDeath()
                }
                entitiesToRemove.insert(copTruckEntity)
                continue
            }

            // Update components
            if let trackingComponent = copTruckEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copTruckEntity.component(ofType: CTDrivingComponent.self) {
                drivingComponent.drive(driveDir: .forward)
                drivingComponent.MOVE_FORCE = gameInfo.copCarSpeed * 2
            }
            if let shootingComponent = copTruckEntity.component(ofType: CTShootingComponent.self) {
                shootingComponent.shoot(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let arrestingComponent = copTruckEntity.component(ofType: CTArrestingCopComponent.self) {
                arrestingComponent.update()
            }
        }

        // Remove marked entities after iteration
        
        gameInfo.numberOfCops -= entitiesToRemove.count
        gameScene.copTruckEntities.removeAll { entitiesToRemove.contains($0) }
    }

    func updateCopTankComponents() {
        guard let gameScene = scene else { return }
        var copTankEntities = gameScene.copTankEntities
        let playerCarEntity = gameScene.playerCarEntity
        var gameInfo = gameScene.gameInfo

        // Track entities already removed
        var entitiesToRemove: Set<CTCopTankEntity> = []

        for copTankEntity in copTankEntities {
            if entitiesToRemove.contains(copTankEntity) {
                continue // Skip already marked entities
            }

            // Calculate distance with player
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(
                pointA: copTankEntity.carNode.position,
                pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)
            ) ?? 0

            // Check despawn distance
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copTankEntity.carNode.removeFromParent()
                entitiesToRemove.insert(copTankEntity)
                continue
            }

            // Check health
            if copTankEntity.carNode.health <= 0.0 {
                if let healthComponent = copTankEntity.component(ofType: CTHealthComponent.self) {
                    healthComponent.applyDeath()
                }
                entitiesToRemove.insert(copTankEntity)
                continue
            }

            // Update components
            if let trackingComponent = copTankEntity.component(ofType: CTSelfDrivingComponent.self) {
                trackingComponent.avoidObstacles()
                trackingComponent.follow(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
            if let drivingComponent = copTankEntity.component(ofType: CTDrivingComponent.self) {
                drivingComponent.drive(driveDir: .forward)
                drivingComponent.MOVE_FORCE = gameInfo.copCarSpeed * 5
            }
            if let shootingComponent = copTankEntity.component(ofType: CTShootingComponent.self) {
                shootingComponent.shoot(target: playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0))
            }
        }

        // Remove marked entities after iteration
        gameInfo.numberOfCops -= entitiesToRemove.count
        gameScene.copTankEntities.removeAll { entitiesToRemove.contains($0) }
    }

    
    // uses an effecient way of capturing the nodes around the player outside a certain rectangle
    func getNodesAround() -> [SKNode] {
        guard let gameScene = scene else { return []}
        
        let playerNode = gameScene.playerCarEntity?.carNode
        let playerPosition = playerNode?.position ?? CGPoint(x: 0.0, y: 0.0)
        let radius = gameScene.gameInfo.PICKUP_SPAWN_RADIUS
        var nearbyNodes: [SKNode] = []
        
        let queryRect = CGRect(x: playerPosition.x - radius, y: playerPosition.y - radius, width: radius * 2, height: radius * 2)
        
        gameScene.physicsWorld.enumerateBodies(in: queryRect) {  body, _ in
            if let node = body.node, node != playerNode, node != gameScene {
                nearbyNodes.append(node)
            }
        }
        return nearbyNodes
    }
    
    // returns a random spawn point around a radius
    // makes sure the point doesn't overlap with any existing object in the scene
    func getRandomSpawnPoint() -> CGPoint {
        
        guard let gameScene = scene else { return CGPoint(x: 0.0, y: 0.0)}
        let playerPosition = gameScene.playerCarEntity?.carNode.position ?? CGPoint(x: 0.0, y: 0.0)
        var spawnPoint: CGPoint
        var isOverlapping = false
        
        repeat {
            // we calculate this because getNodesAround returns nodes outside a certain rectangle.
            // we can find the hypot using the sides of that rect to calculate the spawn radius of our spawn circle
            let spawnRadius = hypot(gameScene.gameInfo.PICKUP_SPAWN_RADIUS, gameScene.gameInfo.PICKUP_SPAWN_RADIUS)
            
            // use polar coordinate to generate a spawn point based on
            let randomAngle = Double(GKRandomDistribution(lowestValue: 0, highestValue: 359).nextInt()) / 180 * .pi
            let spawnPointX = spawnRadius * cos(randomAngle)
            let spawnPointY = spawnRadius * sin(randomAngle)
            
            spawnPoint = CGPoint(x: spawnPointX + playerPosition.x, y: spawnPointY + playerPosition.y)
            
            // Create a frame for the new spawn position
            let spawnRect = CGRect(
                x: spawnPoint.x - gameScene.gameInfo.layoutInfo.fuelSize.width,
                y: spawnPoint.y - gameScene.gameInfo.layoutInfo.fuelSize.height,
                width: gameScene.gameInfo.layoutInfo.fuelSize.width * 2,
                height: gameScene.gameInfo.layoutInfo.fuelSize.height * 2
            )
            
//            let debugNode = SKShapeNode(rect: spawnRect)
//            debugNode.strokeColor = .red
//            debugNode.lineWidth = 2
//            debugNode.path = CGPath(rect: spawnRect, transform: nil)
//            gameScene.addChild(debugNode)
            
            isOverlapping = false
           
            for nodeAround in getNodesAround() {
//                print("Spawn Rect: \(spawnRect)")
//                print("Node Frame: \(nodeAround.calculateAccumulatedFrame())")

                gameScene.physicsWorld.enumerateBodies(in: spawnRect) { body, _ in
                    if let node = body.node, node != gameScene.playerCarEntity?.carNode, node != gameScene, body.node?.name != "road" {
//                        print("Overlap Detected with \(node.name ?? "Unnamed Node")")
                        isOverlapping = true
                    }
                }
            }
            
//            print("No Overlap Detected with Node")
            
        } while isOverlapping
        
        return spawnPoint
    }
    
    func spawnPlayer() {
        
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        let playerCarNode = CTCarNode(imageNamed: "CTplayerCar", size: (context.layoutInfo.playerCarSize) )
        playerCarNode.name = "player"
        playerCarNode.position = CGPoint(x: 0.0, y: 0.0)
        gameScene.playerCarEntity = CTPlayerCarEntity(carNode: playerCarNode)
        gameScene.playerCarEntity?.gameInfo = gameScene.gameInfo
        gameScene.playerCarEntity?.gameScene = gameScene
        gameScene.playerCarEntity?.prepareComponents()
        gameScene.addChild(playerCarNode)
        
    }
    
    
    func handleFuelSpawn () {
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        if !gameScene.gameInfo.isFuelPickedUp { return }
        
        let spawnPoint = getRandomSpawnPoint()
        let fuelNode = CTFuelNode(imageNamed: "CTfuelCan", nodeSize: context.layoutInfo.fuelSize)
        fuelNode.position = spawnPoint
        fuelNode.zPosition = 1
        fuelNode.name = "fuel"
        gameScene.gameInfo.fuelPosition = fuelNode.position
        gameScene.addChild(fuelNode)
        
        gameScene.gameInfo.isFuelPickedUp = false
        
    }
    
    func handleCashSpawn() {
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        if !gameScene.gameInfo.isCashPickedUp { return }
        
        let spawnPoint = getRandomSpawnPoint()
        let cashNode = CTCashNode(imageNamed: "CTlightning", nodeSize: context.layoutInfo.powerupSize)
        cashNode.name = "cash" //TODO: should this be "cash"?
        cashNode.position = spawnPoint
        cashNode.zPosition = 1
        gameScene.addChild(cashNode)
        
        gameScene.gameInfo.isCashPickedUp = false
        
    }
    
    func setGameWaveModeParams(elapsedTime: CGFloat){
        guard let scene else { return }
        
        if (elapsedTime < scene.gameInfo.FIRST_WAVE_TIME)
        {
            scene.gameInfo.wantedLevelLabel.text = "a"
//            copStarIncreaseSound?.play()
            scene.gameInfo.fuelConsumptionRate = 0.06
        }
        if(elapsedTime > scene.gameInfo.FIRST_WAVE_TIME && elapsedTime < scene.gameInfo.FIRST_WAVE_TIME + 1 && !firstWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 2
            scene.gameInfo.playerSpeed += 50
            scene.gameInfo.copCarSpeed += 50
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "aa"
            scene.gameInfo.canSpawnPoliceTrucks = true
            firstWaveSet = true
            copStarIncreaseSound?.play()
            scene.gameInfo.fuelConsumptionRate = 0.085
            scene.gameInfo.starIncreaseEffect()
        }
        if(elapsedTime > scene.gameInfo.SECOND_WAVE_TIME && elapsedTime < scene.gameInfo.SECOND_WAVE_TIME + 1 && !secondWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 2
            scene.gameInfo.playerSpeed += 50
            scene.gameInfo.copCarSpeed += 100
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "aaa"
            secondWaveSet = true
            copStarIncreaseSound?.play()
            scene.gameInfo.fuelConsumptionRate = 0.085
            scene.gameInfo.starIncreaseEffect()
        }
        if(elapsedTime > scene.gameInfo.THIRD_WAVE_TIME && elapsedTime < scene.gameInfo.THIRD_WAVE_TIME + 1 && !thirdWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 2
            scene.gameInfo.playerSpeed += 100
            scene.gameInfo.copCarSpeed += 100
            scene.gameInfo.canSpawnTanks = true
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "aaaa"
            thirdWaveSet = true
            copStarIncreaseSound?.play()
            scene.gameInfo.fuelConsumptionRate = 0.095
            scene.gameInfo.starIncreaseEffect()
        }
        if(elapsedTime > scene.gameInfo.FOURTH_WAVE_TIME && elapsedTime < scene.gameInfo.FOURTH_WAVE_TIME + 1 && !fourthWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 3
            scene.gameInfo.playerSpeed += 50
            scene.gameInfo.copCarSpeed += 50
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "aaaaa"
            fourthWaveSet = true
            copStarIncreaseSound?.play()
            scene.gameInfo.fuelConsumptionRate = 0.1
            scene.gameInfo.starIncreaseEffect()
        }
    }
       
    func handleTouchStart(_ touches: Set<UITouch>) {
//        print("handleTouchStart called")
        
        guard let scene else { return }
        isTouchingSingle = false
        isTouchingDouble = false
         
        if (touches.count == 2) {
            print("reversing")
            isTouchingDouble = true
            self.driveDir = CTDrivingComponent.driveDir.backward
            for touch in touches{
                self.touchLocations.append(touch.location(in: scene.view))
                return
            }
//            print("Two finger control")
        }
        else if(touches.count == 1){
            isTouchingSingle = true
            self.driveDir = CTDrivingComponent.driveDir.forward
            self.touchLocations.append((touches.first?.location(in: scene.view))!)
            
//            print("One finger steering")
        }
    }
    
    func handleTouchEnded(_ touch: UITouch) {
        isTouchingSingle = false
        isTouchingDouble = false
        self.touchLocations = []
        self.moveDirection = 0
        self.driveDir = CTDrivingComponent.driveDir.forward
    }
    
    func handleCameraMovement() {
        let randomNumber = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 5).nextInt())
        let randomOffsetX = sin(time * 2) * (10 + randomNumber)
        let randomOffsetY = cos(time * 2) * (10 + randomNumber)
//        let randomOffsetX = 0.0
//        let randomOffsetY = 0.0
        
        let targetPosition = CGPoint(x: (scene?.playerCarEntity?.carNode.position.x ?? 0.0) + randomOffsetX,  y: (scene?.playerCarEntity?.carNode.position.y ?? 0.0) + randomOffsetY)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.25)
        
        if self.scene?.playerSpeed ?? 101 < 70 {
            let scaleAction = SKAction.scale(to: 0.2, duration: 0.2)
            scene?.cameraNode?.run(scaleAction)
        } else {
            let scaleAction = SKAction.scale(to: 0.35, duration: 0.2)
//            let scaleAction = SKAction.scale(to: 1, duration: 0.2)
            scene?.cameraNode?.run(scaleAction)
        }
        
        scene?.cameraNode?.run(moveAction)
    }
   
}
