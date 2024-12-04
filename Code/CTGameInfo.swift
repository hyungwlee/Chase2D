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
    var isPaused = false
    
    var playerHealth:CGFloat = 100
    var playerSpeed:CGFloat = 810
    var pedSpeed:CGFloat = 500
    var copSpeed:CGFloat = 810
    
    
    var numberOfCops = 0
    var numberOfPeds = 0
    
    var MAX_NUMBER_OF_COPS = 5
    var MAX_NUMBER_OF_PEDS = 10
    let ITEM_DESPAWN_DIST = 30000.0
    let MIN_SPAWN_RADIUS = 500.0
    let MAX_SPAWN_RADIUS = 10000.0
    let MAX_PLAYABLE_SIZE = 1500.0
    let COP_SPAWN_RADIUS = 100.0
    
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
    var numberOfCashNodesInScene = 0 // leave it 0 to begin with and the update function in gameScene will adjust it properly
    let initialCashNumber = 50
    
    var score = 0
    let SCORE_INCREMENT_AMOUNT = 1
    let FREQUENCY_CHANGE_THRESHHOLD = 5 //seconds
    var scoreChangeFrequency = 1.0
    
    // bullet
    var bulletShootInterval = 1
    
    var seconds = 0.0
    var pastValue = ProcessInfo.processInfo.systemUptime
    
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var timeLabel = SKLabelNode(fontNamed: "Arial")
    var healthLabel = SKLabelNode(fontNamed: "Arial")
    var gameOverLabel = SKLabelNode(fontNamed: "Arial")
    var cashLabel = SKLabelNode(fontNamed: "Arial")
    
    var healthIndicator = SKSpriteNode(imageNamed: "player100")
    var speedometer = SKSpriteNode(imageNamed: "speedometer")
    var speedometerBG = SKSpriteNode(imageNamed: "speedometerBG")
    var powerUp = SKSpriteNode()
    
    let speedoSize = 0.31
    
    let layoutInfo: CTLayoutInfo
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), cashLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"))
    {
        self.score = score
        self.layoutInfo = CTLayoutInfo(screenSize: UIScreen.main.bounds.size)
        
        //TODO: Font size needs to scale with screen size
        self.scoreLabel = scoreLabel
        scoreLabel.fontSize = 6
        scoreLabel.zPosition = 100
        
        self.timeLabel = timeLabel
        timeLabel.fontSize = 6
        timeLabel.zPosition = 100
        
        self.healthLabel = healthLabel
        healthLabel.fontSize = 8
        healthLabel.zPosition = 100
        
        self.gameOverLabel = gameOverLabel
        gameOverLabel.fontSize = 12
        gameOverLabel.zPosition = 100
        
        self.cashLabel = cashLabel
        cashLabel.fontSize = 8
        cashLabel.zPosition = 100
        
        // This is the camera zoom value
        let zoomValue = 0.35
        
        healthIndicator.size = CGSize(width: (layoutInfo.screenSize.width / 8) * zoomValue, height: (layoutInfo.screenSize.height / 7) * zoomValue)
        healthIndicator.zPosition = 90
        
        speedometer.size = CGSize(width: layoutInfo.screenSize.width * zoomValue, height: (layoutInfo.screenSize.height / 8) * zoomValue)
        speedometer.zPosition = 100
        speedometer.isHidden = true
        
        speedometerBG.size = CGSize(width: layoutInfo.screenSize.width * zoomValue, height: (layoutInfo.screenSize.height / 8) * zoomValue)
        speedometerBG.zPosition = 95
        speedometerBG.isHidden = true
        
        powerUp.size = CGSize(width: (layoutInfo.screenSize.height / 10) * zoomValue, height: (layoutInfo.screenSize.height / 10) * zoomValue)
        powerUp.zPosition = 101
    }
    
    mutating func setGameOver()
    {
        gameOver = true
    }
    
    func setHealthLabel(value : Double)
    {
        healthLabel.text = "Health: " + String(Int(value))
    }
    
    mutating func updateScore(phoneRuntime: TimeInterval)
    {
        if gameOver
        {
            gameOverLabel.text = "GAME OVER"
            return
        }
        
        if isPaused
        {
            return
        }
        
        if (gameplaySpeed < 1)
        {
            gameplaySpeed += 0.01
        }
        
        seconds += (phoneRuntime - pastValue)
        pastValue = phoneRuntime
        
        timeLabel.text = "Time: " + String(Int(seconds))
        scoreLabel.text = "Score: " + String(score)
        cashLabel.text = "Cash: " + String(cashCollected) + "/3"
        
        let cleanSeconds = Int(Double(String(format: "%.2f", seconds))! * 100)
        if ((cleanSeconds % Int(scoreChangeFrequency * 100)) == 0)
        {
            score += SCORE_INCREMENT_AMOUNT
        }
        
        if (((Int(seconds) % FREQUENCY_CHANGE_THRESHHOLD) == 0) && scoreChangeFrequency >= 0.2)
        {
            scoreChangeFrequency -= 0.1
        }
        
        updateHealthUI()
    }
    
    func updateHealthUI()
    {
        if (playerHealth > 75)
        {
            healthIndicator.texture = SKTexture(imageNamed: "player100")
        }
        else if (playerHealth > 50)
        {
            healthIndicator.texture = SKTexture(imageNamed: "player75")
        }
        else if (playerHealth > 25)
        {
            healthIndicator.texture = SKTexture(imageNamed: "player50")
        }
        else if (playerHealth > 0)
        {
            healthIndicator.texture = SKTexture(imageNamed: "player25")
        }
        else
        {
            healthIndicator.isHidden = true
        }
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
}

