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
//    var stateMachine: GKStateMachine?
    
    // player health and player speed to be implemented later on gameInfo
    // implemented individually now
    var playerHealth:CGFloat = 100
    var playerSpeed:CGFloat = 1000
    var pedSpeed:CGFloat = 800
    var copSpeed:CGFloat = 5000
    
    
    var numberOfCops = 0
    var numberOfPeds = 0
    
    let MAX_NUMBER_OF_COPS = 10
    let MAX_NUMBER_OF_PEDS = 20
    let ITEM_DESPAWN_DIST = 3000.0
    let MIN_SPAWN_RADIUS = 10000.0
    let MAX_SPAWN_RADIUS = 80000.0
    let MAX_PLAYABLE_SIZE = 80000.0
    
    
    
    // gameplay speed
    var gameplaySpeed = 0.01
    
    // cash
    var powerUpPeriod:UInt64 = 2
    var cashCollected = 0
    var numberOfCashNodesInScene = 0 // leave it 0 to begin with and the update function in gameScene will adjust it properly
    let initialCashNumber = 1000
    
    var score = 0
    let SCORE_INCREMENT_AMOUNT = 1
    let FREQUENCY_CHANGE_THRESHHOLD = 5 //seconds
    var scoreChangeFrequency = 1.0
    
    var seconds = 0.0
    var pastValue = ProcessInfo.processInfo.systemUptime
    
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var timeLabel = SKLabelNode(fontNamed: "Arial")
    var healthLabel = SKLabelNode(fontNamed: "Arial")
    var gameOverLabel = SKLabelNode(fontNamed: "Arial")
    
    var healthIndicator = SKSpriteNode(imageNamed: "player100")
    var speedometer = SKSpriteNode(imageNamed: "speedometer")
    var speedometerBG = SKSpriteNode(imageNamed: "speedometerBG")
    let speedoSize = 0.31
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")) {
        self.score = score
        
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
        
        
        healthIndicator.size = CGSize(width: healthIndicator.size.width * 0.25, height: healthIndicator.size.height * 0.25)
        healthIndicator.zPosition = 90
        
        speedometer.size = CGSize(width: speedometer.size.width * speedoSize, height: speedometer.size.height * speedoSize)
        speedometer.zPosition = 100
        
        speedometerBG.size = CGSize(width: speedometerBG.size.width * speedoSize, height: speedometerBG.size.height * speedoSize)
        speedometerBG.zPosition = 95
    }
    
    mutating func setGameOver()
    {
        gameOver = true
    }
    
    func setHealthLabel(value : Double)
    {
//        print(String(Int(value)))
        healthLabel.text = "Health: " + String(Int(value))
    }
    
    mutating func updateScore(phoneRuntime: TimeInterval)
    {
//        guard stateMachine?.currentState is CTGameIdleState else
//        {
//            return
//        }
        if gameOver
        {
            gameOverLabel.text = "GAME OVER"
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
        
        let cleanSeconds = Int(Double(String(format: "%.2f", seconds))! * 100)
        if ((cleanSeconds % Int(scoreChangeFrequency * 100)) == 0)
        {
//            print("REALLY Increasing Score")
            score += SCORE_INCREMENT_AMOUNT
        }
        
        if (((Int(seconds) % FREQUENCY_CHANGE_THRESHHOLD) == 0) && scoreChangeFrequency >= 0.2)
        {
            scoreChangeFrequency -= 0.1
            //increase gamespeed here as well??
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
        let percentage = speed / 200
        let adjWidth = 400 * speedoSize
        let output = (adjWidth * percentage)
//        print("speed: \(speed) percentage: \(percentage)")
        
        return (output - adjWidth)
    }
}

