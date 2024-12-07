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
   }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let scene else { return }
        
        time = seconds
        if !initialTimeSet {
            startTime = seconds
            initialTimeSet = true
        }
        
        let elapsedTime = seconds - startTime
        setGameWaveModeParams(elapsedTime: elapsedTime)
//        print(scene.gameInfo.playerSpeed)
//        print(scene.gameInfo.copSpeed)
//        print(scene.gameInfo.MAX_NUMBER_OF_COPS)
//        print(scene.gameInfo.canSpawnPoliceTrucks)
//        print(scene.gameInfo.canSpawnTanks)
       
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
        
        if scene.playerSpeed < 3.0 && !hasStartedArrest{
            hasStartedArrest = true
            arrestStartTime = seconds
            
        } else {
            hasStartedArrest = false
        }
        
        if hasStartedArrest {
           arrestTimer = seconds - arrestStartTime
            if arrestTimer > 10.0 && scene.playerSpeed < 3.0{
                scene.gameInfo.gameOver = true
                scene.gameInfo.setGameOver()
            }
        }
//        print(hasStartedArrest, arrestTimer, scene.playerSpeed)
        
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
                print(node)
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
            
            let dummyObject = CTFuelNode(imageNamed: "roof2", nodeSize: gameScene.gameInfo.layoutInfo.powerUpSize)
            dummyObject.isHidden = true
            dummyObject.position = spawnPoint
            
            for nodeAround in getNodesAround() {
                isOverlapping = nodeAround.frame.intersects(dummyObject.frame)
            }
            
        } while isOverlapping
        
        return spawnPoint
    }
    
    
    func handleFuelSpawn () {
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        if !gameScene.gameInfo.isFuelPickedUp { return }
        
        let spawnPoint = getRandomSpawnPoint()
        let fuelNode = CTFuelNode(imageNamed: "roof2", nodeSize: context.layoutInfo.powerUpSize)
        fuelNode.position = spawnPoint
        fuelNode.name = "cash"
        fuelNode.zPosition = +1
        gameScene.gameInfo.fuelPosition = fuelNode.position
        gameScene.addChild(fuelNode)
        
        gameScene.gameInfo.isFuelPickedUp = false
        
    }
    
    func handleCashSpawn() {
        guard let context else { return }
        guard let gameScene = scene else { return }
        
        if !gameScene.gameInfo.isCashPickedUp { return }
        
        let spawnPoint = getRandomSpawnPoint()
        let cashNode = CTCashNode(imageNamed: "scoreBoost2", nodeSize: context.layoutInfo.powerUpSize)
        cashNode.name = "fuel"
        cashNode.position = spawnPoint
        cashNode.zPosition = +1
        gameScene.addChild(cashNode)
        
        gameScene.gameInfo.isCashPickedUp = false
        
    }
    
    func setGameWaveModeParams(elapsedTime: CGFloat){
        guard let scene else { return }
        
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
        guard let scene, let context else { return }
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
