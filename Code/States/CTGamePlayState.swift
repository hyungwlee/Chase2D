//
//  CTGameIdelState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import GameplayKit

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
   }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let scene else { return }
        guard let context else { return }
        
        if(scene.gameInfo.gameOver){
            context.stateMachine?.enter(CTGameOverState.self)
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
        if let shootingComponenet = playerCarEntity.component(ofType: CTShootingComponent.self) {
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
    
    func updateCopCarComponents(){
        
        guard let gameScene = scene else { return }
        var copCarEntities = gameScene.copCarEntities
        var playerCarEntity = gameScene.playerCarEntity
        var gameInfo = gameScene.gameInfo
        
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
    }
    func updateCopTruckComponents(){
        
        guard let gameScene = scene else { return }
        var copTruckEntities = gameScene.copTruckEntities
        let playerCarEntity = gameScene.playerCarEntity
        var gameInfo = gameScene.gameInfo
        
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
    }
    
    func updateCopTankComponents() {
        
        guard let gameScene = scene else { return }
        var copTankEntities = gameScene.copTankEntities
        let playerCarEntity = gameScene.playerCarEntity
        var gameInfo = gameScene.gameInfo
        
        for copTankEntity in copTankEntities{
            let distanceWithPlayer = playerCarEntity?.carNode.calculateSquareDistance(pointA: copTankEntity.carNode.position, pointB: playerCarEntity?.carNode.position ?? CGPoint(x: 0, y: 0)) ?? 0
            
            if distanceWithPlayer >= gameInfo.ITEM_DESPAWN_DIST * gameInfo.ITEM_DESPAWN_DIST {
                copTankEntity.carNode.removeFromParent()
                if let index =  copTankEntities.firstIndex(of: copTankEntity) {
                    copTankEntities.remove(at: index)
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
                    copTankEntities.remove(at: index)
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
    
    
    // uses an effecient way of capturing the nodes around the player outside a certain rectangle
    func getNodesAround() -> [SKNode] {
        guard let gameScene = scene else { return []}
        
        let playerNode = gameScene.playerCarEntity?.carNode
        let playerPosition = playerNode?.position ?? CGPoint(x: 0.0, y: 0.0)
        let radius = gameScene.gameInfo.PICKUP_SPAWN_RADIUS + 100
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
                x: spawnPoint.x - gameScene.gameInfo.layoutInfo.powerUpSize.width / 2,
                y: spawnPoint.y - gameScene.gameInfo.layoutInfo.powerUpSize.height / 2,
                width: gameScene.gameInfo.layoutInfo.powerUpSize.width,
                height: gameScene.gameInfo.layoutInfo.powerUpSize.height
            )
            
            let debugNode = SKShapeNode(rect: spawnRect)
            debugNode.strokeColor = .red
            debugNode.lineWidth = 2
//            gameScene.addChild(debugNode)
            
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
    
    func spawnPlayer() {
        
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        let playerCarNode = CTCarNode(imageNamed: "playerCar", size: (context.layoutInfo.playerCarSize) )
        playerCarNode.name = "player"
        playerCarNode.position = CGPoint(x: 0.0, y: 0.0)
        gameScene.playerCarEntity = CTPlayerCarEntity(carNode: playerCarNode)
        gameScene.playerCarEntity?.gameInfo = gameScene.gameInfo
        gameScene.playerCarEntity?.prepareComponents()
        gameScene.addChild(playerCarNode)
        
    }
    
    
    func handleFuelSpawn () {
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        if !gameScene.gameInfo.isFuelPickedUp { return }
        
        let spawnPoint = getRandomSpawnPoint()
        let fuelNode = CTFuelNode(imageNamed: "fuelCan", nodeSize: context.layoutInfo.powerUpSize)
        fuelNode.position = spawnPoint
        fuelNode.name = "cash" //TODO: should this be "fuel"?
        gameScene.gameInfo.fuelPosition = fuelNode.position
        gameScene.addChild(fuelNode)
        
        gameScene.gameInfo.isFuelPickedUp = false
        
    }
    
    func handleCashSpawn() {
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        if !gameScene.gameInfo.isCashPickedUp { return }
        
        let spawnPoint = getRandomSpawnPoint()
        let cashNode = CTCashNode(imageNamed: "scoreBoost", nodeSize: context.layoutInfo.powerUpSize)
        cashNode.name = "fuel" //TODO: should this be "cash"?
        cashNode.position = spawnPoint
        gameScene.addChild(cashNode)
        
        gameScene.gameInfo.isCashPickedUp = false
        
    }
    
    func setGameWaveModeParams(elapsedTime: CGFloat){
        guard let scene else { return }
        
        if (elapsedTime < scene.gameInfo.FIRST_WAVE_TIME)
        {
            scene.gameInfo.wantedLevelLabel.text = "*"
        }
        if(elapsedTime > scene.gameInfo.FIRST_WAVE_TIME && elapsedTime < scene.gameInfo.FIRST_WAVE_TIME + 1 && !firstWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 1
            scene.gameInfo.playerSpeed += 50
            scene.gameInfo.copCarSpeed += 200
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "**"
            scene.gameInfo.canSpawnPoliceTrucks = true
            firstWaveSet = true
            print("firstWaveOver")
        }
        if(elapsedTime > scene.gameInfo.SECOND_WAVE_TIME && elapsedTime < scene.gameInfo.SECOND_WAVE_TIME + 1 && !secondWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 1
            scene.gameInfo.playerSpeed += 150
            scene.gameInfo.copCarSpeed += 200
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "***"
            secondWaveSet = true
            print("secondWaveOver")
        }
        if(elapsedTime > scene.gameInfo.THIRD_WAVE_TIME && elapsedTime < scene.gameInfo.THIRD_WAVE_TIME + 1 && !thirdWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 1
            scene.gameInfo.playerSpeed += 100
            scene.gameInfo.copCarSpeed += 150
            scene.gameInfo.canSpawnTanks = true
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "****"
            thirdWaveSet = true
            print("thirdwaveover")
        }
        if(elapsedTime > scene.gameInfo.FOURTH_WAVE_TIME && elapsedTime < scene.gameInfo.FOURTH_WAVE_TIME + 1 && !fourthWaveSet) {
            scene.gameInfo.MAX_NUMBER_OF_COPS += 2
            scene.gameInfo.playerSpeed += 100
            scene.gameInfo.copCarSpeed += 100
            scene.gameInfo.currentWave += 1
            scene.gameInfo.wantedLevelLabel.text = "*****"
            fourthWaveSet = true
            print("fourthWaveOver")
        }
    }
       
    func handleTouchStart(_ touches: Set<UITouch>) {
        guard let scene else { return }
        isTouchingSingle = false
        isTouchingDouble = false
         
        let loc = touches.first?.location(in: scene.view)
        
        
        // this code is for emulator only
        if(loc?.y ?? 0.0 > (scene.frame.height - 100)){
            isTouchingDouble = true
            self.driveDir = CTDrivingComponent.driveDir.backward
            self.moveDirection = -1.0
            for touch in touches{
                self.touchLocations.append(touch.location(in: scene.view))
                return
            }
        }else if(touches.count == 1){
            isTouchingSingle = true
            self.driveDir = CTDrivingComponent.driveDir.forward
            self.touchLocations.append((touches.first?.location(in: scene.view))!)
        }
        
//        if(touches.count > 1){
//            isTouchingDouble = true
//            for touch in touches{
//                self.touchLocations?.append(touch.location(in: scene.view))
//            }
//        }else if(touches.count == 1){
//            isTouchingSingle = true
//            self.touchLocations?.append((touches.first?.location(in: scene.view))!)
//        }
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
