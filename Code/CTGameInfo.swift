//
//  File.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import Foundation
import SpriteKit
import GameplayKit

class CTGameInfo {
    var gameOver = false
    var isPaused = true
    
    var playerHealth:CGFloat = 300
    let playerStartingHealth: CGFloat
    var playerSpeed:CGFloat = 810
    
    var fuelConsumptionRate = 0.085
    
    var pedSpeed:CGFloat = 500
    var copCarSpeed:CGFloat = 810
    var copSpeed:CGFloat = 20
    
    var numberOfCops = 0
    var numberOfPeds = 0
    
    var MAX_NUMBER_OF_COPS = 10
    var MAX_NUMBER_OF_PEDS = 10
    let ITEM_DESPAWN_DIST = 300.0
    let MIN_SPAWN_RADIUS = 200.0
    let MAX_SPAWN_RADIUS = 1000.0
    let MAX_PLAYABLE_SIZE = 1500.0
    let COP_SPAWN_RADIUS = 150.0
    let PICKUP_SPAWN_RADIUS = 400.0
    
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
    
    var timeLabel = SKLabelNode(fontNamed:          "Eating Pasta")
    var gameOverLabel = SKLabelNode(fontNamed:      "Eating Pasta")
    var reverseLabel = SKLabelNode(fontNamed:       "Eating Pasta")
    var fuelLabel = SKLabelNode(fontNamed:          "Eating Pasta")
    var fuelValue = SKLabelNode(fontNamed:          "Eating Pasta")
    var wantedLevelLabel = SKLabelNode(fontNamed:   "Star Things")
    var tapToStartLabel = SKLabelNode(fontNamed:    "Eating Pasta")
    var instructionsLabel = SKLabelNode(fontNamed:  "Eating Pasta")
    var powerupLabel = SKLabelNode(fontNamed:       "Eating Pasta")
    var powerupHintLabel = SKLabelNode(fontNamed:   "Eating Pasta")
    var lowFuelAlert = SKLabelNode(fontNamed:       "Eating Pasta")
    let starDupe = SKLabelNode(fontNamed:           "Star Things")
    
    var powerUp = SKSpriteNode()
    
    var logo = SKSpriteNode(imageNamed: "CTchase2dLogo")
    var instructions = SKSpriteNode(imageNamed: "CTstartingInstructions")
    
    let restartButton = CTRestartButtonNode(text: "Restart", size: CGSize(width: 50, height: 25), backgroundColor: UIColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0))
    
    var backgroundNode = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), size: CGSize(width: 1000, height: 1000))
    
    var readyToRestart = false
    var pressedPlay = false
    
    let layoutInfo: CTLayoutInfo
    
    init(score: Int = 0)
    {
        readyToRestart = false
        playerStartingHealth = playerHealth
        self.score = score
        self.layoutInfo = CTLayoutInfo(screenSize: UIScreen.main.bounds.size)
        let zoomValue = 0.35            // This is the camera zoom value
        
        
//      ###  UI Element Scaling:  ###
        
        timeLabel.setScale(             0.0007 * layoutInfo.screenSize.height)
        gameOverLabel.setScale(         0.00065 * layoutInfo.screenSize.height)
        reverseLabel.setScale(          0.000225 * layoutInfo.screenSize.height)
        fuelLabel.setScale(             0.0004 * layoutInfo.screenSize.height)
        fuelValue.setScale(             0.0004 * layoutInfo.screenSize.height)
        wantedLevelLabel.setScale(      0.0004 * layoutInfo.screenSize.height)
        powerupLabel.setScale(          0.00035 * layoutInfo.screenSize.height)
        powerupHintLabel.setScale(      0.00025 * layoutInfo.screenSize.height)
        tapToStartLabel.setScale(       0.00025 * layoutInfo.screenSize.height)
        instructionsLabel.setScale(     0.00013 * layoutInfo.screenSize.height)
        logo.setScale(                  0.00025 * layoutInfo.screenSize.height)
        instructions.setScale(          0.0002 * layoutInfo.screenSize.height)
        restartButton.setScale(         0.001 * layoutInfo.screenSize.height)
        lowFuelAlert.setScale(          0.0004 * layoutInfo.screenSize.height)
        starDupe.setScale(              0.0005 * layoutInfo.screenSize.height) // Original is 0.0004
        
        
        //  Positioning information can be found in CTGameScene.
        
        
//      ###  UI Element Z position/layers:  ###

        backgroundNode.zPosition =      50
        starDupe.zPosition =            89
        reverseLabel.zPosition =        90
        wantedLevelLabel.zPosition =    90
        timeLabel.zPosition =           100
        instructions.zPosition =        100
        powerupHintLabel.zPosition =    101
        powerupLabel.zPosition =        101
        powerUp.zPosition =             101
        fuelLabel.zPosition =           102
        tapToStartLabel.zPosition =     102
        fuelValue.zPosition =           102
        instructionsLabel.zPosition =   102
        lowFuelAlert.zPosition =        102
        logo.zPosition =                1000
        restartButton.zPosition =       1001
        gameOverLabel.zPosition =       2000
        
        
        
//      ###  UI Starting Visibility:  ###
        
        gameOverLabel.isHidden =        true
        reverseLabel.isHidden =         true
        fuelLabel.isHidden =            true
        fuelValue.isHidden =            true
        powerupLabel.isHidden =         true
        powerupHintLabel.isHidden =     true
        restartButton.isHidden =        true
        backgroundNode.isHidden =       true
        lowFuelAlert.isHidden =         true
        starDupe.isHidden =             true
        
        
//      ###  Text Element Values  ###
        
        gameOverLabel.text =            "GAME OVER"
        reverseLabel.text =             "Two Fingers to Reverse!"
        fuelLabel.text =                "Fuel:"
        tapToStartLabel.text =          "Tap to Start!"
        instructionsLabel.text =        "Avoid the Police & Don't Run Out of Fuel!"
        lowFuelAlert.text =             "!! LOW FUEL !!"
        
        
        
//      ###  Miscellaneous  ###
        
        fuelLabel.fontColor = .white // I think the default is white, so this may be unnecessary
        instructionsLabel.fontColor = .orange
        lowFuelAlert.fontColor = .red
        restartButton.yScale = 0.8
        backgroundNode.alpha = 0.5
        starDupe.fontColor = .white
        starDupe.alpha = 0.85
        
        
//      ###  Stars Animation  ###
        
        let changeToBlue = SKAction.run { self.wantedLevelLabel.fontColor = .blue }
        let changeToRed = SKAction.run { self.wantedLevelLabel.fontColor = .red }
        let wait = SKAction.wait(forDuration: 1.0)
        let colorCycle = SKAction.sequence([changeToBlue, wait, changeToRed, wait])
        wantedLevelLabel.run(SKAction.repeatForever(colorCycle))
        
//      ###  Tap to Start Animation  ###
        
        let startFadeIn = SKAction.fadeIn(withDuration: 0.5)
        let startFadeOut = SKAction.fadeOut(withDuration: 0.75)
        let startSeq = SKAction.sequence([startFadeIn, startFadeOut])
        tapToStartLabel.run(SKAction.repeatForever(startSeq))
        
//      ###  Low Fuel Alert Animation  ###
        
        let lowFuelFadeIn = SKAction.fadeIn(withDuration: 0.35)
        let lowFuelFadeOut = SKAction.fadeOut(withDuration: 0.5)
        let lowFuelSeq = SKAction.sequence([lowFuelFadeIn, lowFuelFadeOut])
        lowFuelAlert.run(SKAction.repeatForever(lowFuelSeq))
        
        
        //  Not sure if this necessarily needs to be here...
        powerUp.size = CGSize(width: (layoutInfo.screenSize.height / 10) * zoomValue, height: (layoutInfo.screenSize.height / 10) * zoomValue)
    }
    
    func setGameOver()
    {
        gameOver = true
    }
    
    func updateScore(phoneRuntime: TimeInterval)
    {
        if gameOver
        {
            gameOverLabel.isHidden = false
            backgroundNode.isHidden = false
            return
        }
        
        if fuelLevel < 35 && fuelLevel > 0
        {
            lowFuelAlert.isHidden = false
        }
        else {lowFuelAlert.isHidden = true}
        
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
            
            fuelLabel.isHidden = false
            fuelValue.isHidden = false
            
            if !pressedPlay
            {
                score = 0
                pastValue = ProcessInfo.processInfo.systemUptime
            }
            
            pressedPlay = true
        }
        
        if (gameplaySpeed < 1)
        {
            gameplaySpeed += 0.01
        }
        
        if pressedPlay
        {
            seconds += (phoneRuntime - pastValue)
            pastValue = phoneRuntime
        }
        
        timeLabel.text = String(Int(seconds))
    }
    
    func updateSpeed(speed: CGFloat) -> CGFloat
    {
        let percentage = speed / 150
        let offset = layoutInfo.screenSize.width * 0.85
        return (layoutInfo.screenSize.width * percentage - offset)
    }
    
    func setIsPaused(val: Bool)
    {
        isPaused = val
    }
    
    func setReverseIsHiddenVisibility(val: Bool)
    {
        reverseLabel.isHidden = val
    }
    
    func consumeFuel()
    {
        if !gameOver
        {
            fuelLevel -= fuelConsumptionRate
        }
        else {fuelLevel = 0}
    }
    
    func refillFuel(amount: CGFloat)
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
    
    func updateFuelUI()
    {
        if (fuelLevel > 75)
        {
            fuelValue.fontColor = .green
            fuelValue.setScale(0.40)
        }
        else if (fuelLevel > 50)
        {
            fuelValue.fontColor = .yellow
            fuelValue.setScale(0.42)
        }
        else if (fuelLevel > 25)
        {
            fuelValue.fontColor = .orange
            fuelValue.setScale(0.44)
        }
        else
        {
            fuelValue.fontColor = .red
            fuelValue.setScale(0.48)
        }
        
        if (fuelLevel > 0 && !gameOver && !isPaused)
        {
            fuelValue.text = String(Int(fuelLevel)) + "%"
        }
        else if (fuelLevel <= 0)
        {
            fuelValue.isHidden = true
            fuelLabel.text = "Out of Fuel"
            fuelLabel.fontColor = .red
            
            arrestMade()
        }
    }
    
    func arrestMade()
    {
        gameOver = true
        gameOverLabel.text = "Arrested"
    }
    
//  ###  Star Increase Animation  ###
    func starIncreaseEffect()
    {
        starDupe.text = wantedLevelLabel.text
        starDupe.isHidden = false
        
        let starPulse = SKAction.fadeOut(withDuration: 1.5)
        let starHide = SKAction.run {self.starDupe.isHidden = true}
        let starSeq = SKAction.sequence([starPulse, starHide])
        starDupe.run(starSeq)
    }
    
    
     func reset() {
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
        pastValue = ProcessInfo.processInfo.systemUptime
        scoreChangeFrequency = 1.0
        bulletShootInterval = 1
        
        gameOverLabel.isHidden = true
        restartButton.isHidden = true
        logo.isHidden = false
        backgroundNode.isHidden = true
        
        fuelLabel.text = "Fuel:"
        fuelLabel.fontColor = .white
    }
}
