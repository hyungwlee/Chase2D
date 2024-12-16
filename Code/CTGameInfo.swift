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
    
    let fuelConsumptionRate = 0.09
    
    var pedSpeed:CGFloat = 500
    var copCarSpeed:CGFloat = 810
    var copSpeed:CGFloat = 20
    
    
    var numberOfCops = 0
    var numberOfPeds = 0
    
    var MAX_NUMBER_OF_COPS = 5
    var MAX_NUMBER_OF_PEDS = 10
    let ITEM_DESPAWN_DIST = 500.0
    let MIN_SPAWN_RADIUS = 500.0
    let MAX_SPAWN_RADIUS = 10000.0
    let MAX_PLAYABLE_SIZE = 1500.0
    let COP_SPAWN_RADIUS = 150.0
    let PICKUP_SPAWN_RADIUS = 350.0
    
    let FIRST_WAVE_TIME     = 20.0
    let SECOND_WAVE_TIME    = 40.0
    let THIRD_WAVE_TIME     = 90.0
    let FOURTH_WAVE_TIME    = 300.0
//
    
    // debug values
//    let FIRST_WAVE_TIME     = 5.0
//    let SECOND_WAVE_TIME    = 5.0
//    let THIRD_WAVE_TIME     = 5.0
//    let FOURTH_WAVE_TIME    = 5.0
    
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
    
//    var scoreLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var timeLabel = SKLabelNode(fontNamed: "Eating Pasta")
//    var healthLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var gameOverLabel = SKLabelNode(fontNamed: "Eating Pasta")
//    var cashLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var reverseLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var fuelLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var wantedLevelLabel = SKLabelNode(fontNamed: "Star Things")
    var tapToStartLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var instructionsLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var powerupLabel = SKLabelNode(fontNamed: "Eating Pasta")
    var powerupHintLabel = SKLabelNode(fontNamed: "Eating Pasta")
    
//    var healthIndicator = SKSpriteNode(imageNamed: "player100")
//    var speedometer = SKSpriteNode(imageNamed: "speedometer")
//    var speedometerBG = SKSpriteNode(imageNamed: "speedometerBG")
    var powerUp = SKSpriteNode()
    
    var logo = SKSpriteNode(imageNamed: "chase2dLogo")
    var instructions = SKSpriteNode(imageNamed: "startingInstructions")
    
    let restartButton = CTRestartButtonNode(text: "Restart", size: CGSize(width: 50, height: 25), backgroundColor: UIColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0))
    
    var backgroundNode = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), size: CGSize(width: 1000, height: 1000))
    
    var readyToRestart = false
    
    
//    let blurryOverlay = SKEffectNode()
//    let blurFilter = CIFilter(name: "CIGaussianBlur")
    
//    let speedoSize = 0.31
    
    let layoutInfo: CTLayoutInfo
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, /*scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"),*/ timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), /*healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"),*/ gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), /*cashLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"),*/ reverseLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), fuelLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), wantedLevelLabel: SKLabelNode = SKLabelNode(fontNamed: "Star Things"), tapToStartLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), instructionsLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), powerupLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), powerupHintLabel: SKLabelNode = SKLabelNode(fontNamed: "Eating Pasta"), logo: SKSpriteNode = SKSpriteNode(imageNamed: "chase2dLogo"), instructions: SKSpriteNode = SKSpriteNode(imageNamed: "startingInstructions"))
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
//        timeLabel.fontSize = 6
//        timeLabel.fontSize = layoutInfo.screenSize.width / 45
        timeLabel.setScale(0.5)
        timeLabel.zPosition = 100
        
//        self.healthLabel = healthLabel
//        healthLabel.fontSize = 8
//        healthLabel.zPosition = 100
//        healthLabel.isHidden = true
        
        self.gameOverLabel = gameOverLabel
//        gameOverLabel.fontSize = 12
//        gameOverLabel.fontSize = layoutInfo.screenSize.width / 33
        gameOverLabel.setScale(0.5)
        gameOverLabel.zPosition = 100
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.isHidden = true
        
//        self.cashLabel = cashLabel
//        cashLabel.fontSize = 8
//        cashLabel.zPosition = 100
        
        self.reverseLabel = reverseLabel
//        reverseLabel.fontSize = 6
//        reverseLabel.fontSize = layoutInfo.screenSize.width / 66
        reverseLabel.setScale(0.2)
        reverseLabel.zPosition = 90
        reverseLabel.isHidden = true
        reverseLabel.text = "Throw it in Reverse!"
        
        self.fuelLabel = fuelLabel
//        fuelLabel.fontSize = 8
//        fuelLabel.fontSize = layoutInfo.screenSize.width / 66
        fuelLabel.setScale(0.4)
        fuelLabel.zPosition = 102
        
        self.wantedLevelLabel = wantedLevelLabel
//        wantedLevelLabel.fontSize = 10
//        wantedLevelLabel.fontSize = layoutInfo.screenSize.width / 45
        wantedLevelLabel.setScale(0.5)
        wantedLevelLabel.zPosition = 90
        wantedLevelLabel.text = "b"
        
        self.powerupLabel = powerupLabel
//        powerupLabel.fontSize = 10
//        powerupLabel.fontSize = layoutInfo.screenSize.width / 33
        powerupLabel.setScale(0.35)
        powerupLabel.zPosition = 101
        powerupLabel.isHidden = true
        
        self.powerupHintLabel = powerupHintLabel
//        powerupHintLabel.fontSize = 8
//        powerupHintLabel.fontSize = layoutInfo.screenSize.width / 66
        powerupHintLabel.setScale(0.2)
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
//        tapToStartLabel.fontSize = 8
//        tapToStartLabel.fontSize = layoutInfo.screenSize.width / 45
        tapToStartLabel.setScale(0.25)
        tapToStartLabel.zPosition = 102
        tapToStartLabel.text = "Tap to Start!"
        
        self.instructionsLabel = instructionsLabel
//        instructionsLabel.fontSize = 6
//        instructionsLabel.fontSize = layoutInfo.screenSize.width / 100
        instructionsLabel.setScale(0.12)
        instructionsLabel.zPosition = 102
        instructionsLabel.text = "Avoid the Police & Don't Run Out of Fuel!"
        instructionsLabel.fontColor = .orange
        
        self.logo = logo
        logo.size = CGSize(width: layoutInfo.screenSize.width / 5, height: layoutInfo.screenSize.height / 10)
        logo.zPosition = 1000
        
        self.instructions = instructions
        let instructionsWidth = layoutInfo.screenSize.width * 0.16
        instructions.zPosition = 100
        instructions.size = CGSize(width: instructionsWidth, height: instructionsWidth)
        
        restartButton.zPosition = 1001
        restartButton.yScale = 0.8
        restartButton.setScale(0.75)
//        restart.onTap = {
////            print("restart button pressed")
//            readyToRestart = true
//        }
        restartButton.isHidden = true
        
        
//        blurryOverlay.shouldEnableEffects = false
//        blurFilter?.setValue(10.0, forKey: kCIInputRadiusKey) // Adjust blur intensity
//        blurryOverlay.filter = blurFilter
        
        
        backgroundNode.zPosition = 50
        backgroundNode.alpha = 0.5
        backgroundNode.isHidden = true
    }
    
    mutating func setGameOver()
    {
        gameOver = true
        
//        blurryOverlay.shouldEnableEffects = true
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
            backgroundNode.isHidden = false
            
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
            logo.isHidden = true
            instructions.isHidden = true
        }
        
        if (gameplaySpeed < 1)
        {
            gameplaySpeed += 0.01
        }
        
        seconds += (phoneRuntime - pastValue)
        pastValue = phoneRuntime
        
        timeLabel.text = String(Int(seconds))
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
        
//        updateHealthUI()
    }
    
//    func updateHealthUI()
//    {
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
//    }
    
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
        if !gameOver
        {
            fuelLevel -= fuelConsumptionRate
        }
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
        if (fuelLevel > 75)
        {
            fuelLabel.fontColor = .green
            fuelLabel.setScale(0.40)
        }
        else if (fuelLevel > 50)
        {
            fuelLabel.fontColor = .yellow
            fuelLabel.setScale(0.42)
        }
        else if (fuelLevel > 25)
        {
            fuelLabel.fontColor = .orange
            fuelLabel.setScale(0.44)
        }
        else
        {
            fuelLabel.fontColor = .red
            fuelLabel.setScale(0.48)
        }
        
        if (fuelLevel > 0 && !gameOver && !isPaused)
        {
            fuelLabel.text = "Fuel: " + String(Int(fuelLevel)) + "%"
        }
        else if (fuelLevel <= 0)
        {
            fuelLabel.text = "Out of Fuel"
            
            arrestMade()
//            gameOverLabel.text = "Game Over"
        }
    }
    
    mutating func arrestMade()
    {
        gameOver = true
        gameOverLabel.text = "Arrested"
    }
    
    //    func wantedLights(freq: CGFloat)
    //    {
    //        // Create the actions
    //        let changeToRed = SKAction.run { wantedLevelLabel.fontColor = .red }
    //        let changeToBlue = SKAction.run { wantedLevelLabel.fontColor = .blue }
    //        let wait = SKAction.wait(forDuration: freq) // Specify the duration between color switches
    //        let colorChangeSequence = SKAction.sequence([changeToRed, wait, changeToBlue, wait])
    ////        wantedLevelLabel.run(SKAction.repeatForever(colorChangeSequence))
    //        wantedLevelLabel.run(colorChangeSequence)
    //    }
    
    mutating func reset() {
        
        gameOver = false
        isPaused = true
        seconds = 0
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
        
//        blurryOverlay.shouldEnableEffects = false
        
        gameOverLabel.isHidden = true
        restartButton.isHidden = true
        logo.isHidden = false
        backgroundNode.isHidden = true
    }
}
