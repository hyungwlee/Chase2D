//
//  File.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import Foundation
import SpriteKit
import GameplayKit

struct CTGameInfo {
    var gameOver = false
    var isPaused = true
    
    var playerHealth:CGFloat = 300
    let playerStartingHealth: CGFloat
    var playerSpeed:CGFloat = 810
//    var playerForwardSpeed: CGFloat = 0
    
    let fuelConsumptionRate = 0.07
    
    var pedSpeed:CGFloat = 500
    var copCarSpeed:CGFloat = 810
    var copSpeed:CGFloat = 20
    
    
    var numberOfCops = 0
    var numberOfPeds = 0
    
    var MAX_NUMBER_OF_COPS = 5
    var MAX_NUMBER_OF_PEDS = 10
    let ITEM_DESPAWN_DIST = 30000.0
    let MIN_SPAWN_RADIUS = 500.0
    let MAX_SPAWN_RADIUS = 10000.0
    let MAX_PLAYABLE_SIZE = 1500.0
    let COP_SPAWN_RADIUS = 150.0
    let PICKUP_SPAWN_RADIUS = 200.0
    
    let FIRST_WAVE_TIME     = 20.0
    let SECOND_WAVE_TIME    = 40.0
    let THIRD_WAVE_TIME     = 90.0
    let FOURTH_WAVE_TIME    = 300.0
    
    var currentWave = 0
    
    var canSpawnPoliceTrucks = false
    var canSpawnTanks = false
    var gunShootInterval = 700_000_000
    
    
    // gameplay speed
    var gameplaySpeed = 0.01
    
    // cash
    var powerUpPeriod:UInt64 = 2
    var cashCollected = 0
    var isFuelPickedUp = true
    var isCashPickedUp = true
    var fuelPosition = CGPoint(x: 0.0, y: 0.0)
    
    
    var fuelLevel: CGFloat = 100.0
    
    var score = 0
    let SCORE_INCREMENT_AMOUNT = 1
    let FREQUENCY_CHANGE_THRESHHOLD = 5 //seconds
    var scoreChangeFrequency = 1.0
    
    // bullet
    var bulletShootInterval = 1
    
    var seconds = 0.0
    var pastValue = ProcessInfo.processInfo.systemUptime
    
//    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var timeLabel = SKLabelNode(fontNamed: "Arial")
//    var healthLabel = SKLabelNode(fontNamed: "Arial")
    var gameOverLabel = SKLabelNode(fontNamed: "Arial")
//    var cashLabel = SKLabelNode(fontNamed: "Arial")
    var reverseLabel = SKLabelNode(fontNamed: "Arial")
    var fuelLabel = SKLabelNode(fontNamed: "Arial")
    var wantedLevelLabel = SKLabelNode(fontNamed: "MarkerFelt-Thin")
    var tapToStartLabel = SKLabelNode(fontNamed: "Arial")
    var instructionsLabel = SKLabelNode(fontNamed: "Arial")
    var powerupLabel = SKLabelNode(fontNamed: "Arial")
    var powerupHintLabel = SKLabelNode(fontNamed: "Arial")
    
//    var healthIndicator = SKSpriteNode(imageNamed: "player100")
//    var speedometer = SKSpriteNode(imageNamed: "speedometer")
//    var speedometerBG = SKSpriteNode(imageNamed: "speedometerBG")
    var powerUp = SKSpriteNode()
    
    let restartButton = CTRestartButtonNode(text: "Restart", size: CGSize(width: 50, height: 25), backgroundColor: UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0))
    var readyToRestart = false
    
//    let speedoSize = 0.31
    
    let layoutInfo: CTLayoutInfo
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, /*scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"),*/ timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), /*healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"),*/ gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), /*cashLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"),*/ reverseLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), fuelLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), wantedLevelLabel: SKLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Thin"), tapToStartLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), instructionsLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), powerupLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), powerupHintLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"))
    {
        readyToRestart = false
        playerStartingHealth = playerHealth
        
        self.score = score
        self.layoutInfo = CTLayoutInfo(screenSize: UIScreen.main.bounds.size)
        
        //TODO: Font size needs to scale with screen size
//        self.scoreLabel = scoreLabel
//        scoreLabel.fontSize = 6
//        scoreLabel.zPosition = 100
//        // comment the line below if you want to display score
//        scoreLabel.isHidden = true
        
        self.timeLabel = timeLabel
        timeLabel.fontSize = 6
        timeLabel.zPosition = 100
        
//        self.healthLabel = healthLabel
//        healthLabel.fontSize = 8
//        healthLabel.zPosition = 100
//        healthLabel.isHidden = true
        
        self.gameOverLabel = gameOverLabel
        gameOverLabel.fontSize = 12
        gameOverLabel.zPosition = 100
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.isHidden = true
        
//        self.cashLabel = cashLabel
//        cashLabel.fontSize = 8
//        cashLabel.zPosition = 100
        
        self.reverseLabel = reverseLabel
        reverseLabel.fontSize = 6
        reverseLabel.zPosition = 90
        reverseLabel.isHidden = true
        reverseLabel.text = "Throw it in Reverse!"
        
        self.fuelLabel = fuelLabel
        fuelLabel.fontSize = 8
        fuelLabel.zPosition = 102
        
        self.wantedLevelLabel = wantedLevelLabel
        wantedLevelLabel.fontSize = 10
        wantedLevelLabel.zPosition = 90
        wantedLevelLabel.text = "*"
        
        self.powerupLabel = powerupLabel
        powerupLabel.fontSize = 10
        powerupLabel.zPosition = 101
        powerupLabel.isHidden = true
        
        self.powerupHintLabel = powerupHintLabel
        powerupHintLabel.fontSize = 8
        powerupHintLabel.zPosition = 101
        powerupHintLabel.isHidden = true
//        powerupHintLabel.text = "Tap the screen to activate!"
        
        // This is the camera zoom value
        let zoomValue = 0.35
        
//        healthIndicator.size = CGSize(width: (layoutInfo.screenSize.width / 8) * zoomValue, height: (layoutInfo.screenSize.height / 7) * zoomValue)
//        healthIndicator.zPosition = 90
//        healthIndicator.isHidden = true
//        
//        speedometer.size = CGSize(width: layoutInfo.screenSize.width * zoomValue, height: (layoutInfo.screenSize.height / 8) * zoomValue)
//        speedometer.zPosition = 100
//        speedometer.isHidden = true
//        
//        speedometerBG.size = CGSize(width: layoutInfo.screenSize.width * zoomValue, height: (layoutInfo.screenSize.height / 8) * zoomValue)
//        speedometerBG.zPosition = 95
//        speedometerBG.isHidden = true
        
        powerUp.size = CGSize(width: (layoutInfo.screenSize.height / 10) * zoomValue, height: (layoutInfo.screenSize.height / 10) * zoomValue)
        powerUp.zPosition = 101
        
        self.tapToStartLabel = tapToStartLabel
        tapToStartLabel.fontSize = 8
        tapToStartLabel.zPosition = 102
        tapToStartLabel.text = "Tap to Start!"
        
        self.instructionsLabel = instructionsLabel
        instructionsLabel.fontSize = 6
        instructionsLabel.zPosition = 102
        instructionsLabel.text = "Avoid the Police and Don't Run Out of Fuel!"
        
        restartButton.zPosition = 1000
//        restart.onTap = {
////            print("restart button pressed")
//            readyToRestart = true
//        }
        restartButton.isHidden = true
    }
    
    mutating func setGameOver()
    {
        gameOver = true
    }
    
//    func setHealthLabel(value : Double)
//    {
//        healthLabel.text = "Health: " + String(Int(value))
//    }
    
    mutating func updateScore(phoneRuntime: TimeInterval)
    {
        if gameOver
        {
            gameOverLabel.isHidden = false
            return
        }
        
        if isPaused
        {
            return
        }
        else
        {
            tapToStartLabel.isHidden = true
            instructionsLabel.isHidden = true
        }
        
        if (gameplaySpeed < 1)
        {
            gameplaySpeed += 0.01
        }
        
        seconds += (phoneRuntime - pastValue)
        pastValue = phoneRuntime
        
        timeLabel.text = "Time: " + String(Int(seconds))
//        scoreLabel.text = "Score: " + String(score)
//        cashLabel.text = "Cash: " + String(cashCollected) + "/3"
//        cashLabel.isHidden = true
        
//        let cleanSeconds = Int(Double(String(format: "%.2f", seconds))! * 100)
//        if ((cleanSeconds % Int(scoreChangeFrequency * 100)) == 0)
//        {
//            score += SCORE_INCREMENT_AMOUNT
//        }
//        
//        if (((Int(seconds) % FREQUENCY_CHANGE_THRESHHOLD) == 0) && scoreChangeFrequency >= 0.2)
//        {
//            scoreChangeFrequency -= 0.1
//        }
        
        updateHealthUI()
    }
    
    func updateHealthUI()
    {
//        if (playerHealth > playerStartingHealth * 0.75)
//        {
//            healthIndicator.texture = SKTexture(imageNamed: "player100")
//        }
//        else if (playerHealth > playerStartingHealth * 0.5)
//        {
//            healthIndicator.texture = SKTexture(imageNamed: "player75")
//        }
//        else if (playerHealth > playerStartingHealth * 0.25)
//        {
//            healthIndicator.texture = SKTexture(imageNamed: "player50")
//        }
//        else if (playerHealth > 0)
//        {
//            healthIndicator.texture = SKTexture(imageNamed: "player25")
//        }
//        else
//        {
//            healthIndicator.isHidden = true
//        }
    }
    
    func updateSpeed(speed: CGFloat) -> CGFloat
    {
        let percentage = speed / 150
        let offset = layoutInfo.screenSize.width * 0.85
        return (layoutInfo.screenSize.width * percentage - offset)
    }
    
    mutating func setIsPaused(val: Bool)
    {
        isPaused = val
    }
    
//    mutating func increasePlayerHealth(amount: CGFloat)
//    {
//        playerHealth += amount
//    }
//    
//    mutating func decreasePlayerHealth(amount: CGFloat)
//    {
////        playerHealth -= amount
//    }
    
    mutating func setReverseIsHiddenVisibility(val: Bool)
    {
        reverseLabel.isHidden = val
    }
    
    mutating func consumeFuel()
    {
        fuelLevel -= fuelConsumptionRate
    }
    
    mutating func refillFuel(amount: CGFloat)
    {
        if ((fuelLevel + amount) < 100.0)
        {
            fuelLevel += amount
        }
        else
        {
            fuelLevel = 100.0
        }
    }
    
    mutating func updateFuelUI()
    {
        if (fuelLevel > 0 && !gameOver && !isPaused)
        {
            fuelLabel.text = "Fuel: " + String(Int(fuelLevel)) + "%"
        }
        else if (fuelLevel <= 0)
        {
            fuelLabel.text = "Out of Fuel"
            
            arrestMade()
            gameOverLabel.text = "Game Over"
        }
    }
    
    mutating func arrestMade()
    {
        gameOver = true
        gameOverLabel.text = "Arrested"
    }
    
    mutating func reset() {
        
        gameOver = false
        isPaused = true
        playerSpeed = 810
        copCarSpeed = 810
        copSpeed = 20
        numberOfCops = 0
        MAX_NUMBER_OF_COPS = 5
        MAX_NUMBER_OF_PEDS = 10
        currentWave = 0
        canSpawnPoliceTrucks = false
        canSpawnTanks = false
        gunShootInterval = 700_000_000
        powerUpPeriod = 2
        cashCollected = 0
        isFuelPickedUp = true
        isCashPickedUp = true
        fuelPosition = CGPoint(x: 0.0, y: 0.0)
        fuelLevel = 100.0
        score = 0
        scoreChangeFrequency = 1.0
        bulletShootInterval = 1
        
        gameOverLabel.isHidden = true
        restartButton.isHidden = true
    }
}

