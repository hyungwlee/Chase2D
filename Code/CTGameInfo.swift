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
    var playerSpeed:CGFloat = 1350
    var pedSpeed:CGFloat = 800
    var copSpeed:CGFloat = 1300
    
    
    var numberOfCops = 0
    var numberOfPeds = 0
    
    let MAX_NUMBER_OF_COPS = 10
    let MAX_NUMBER_OF_PEDS = 20
    
    
    // gameplay speed
    var gameplaySpeed = 0.01
    
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
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")) {
        self.score = score
        
        self.scoreLabel = scoreLabel
        scoreLabel.fontSize = 6
        scoreLabel.zPosition = 100
        
        self.timeLabel = timeLabel
        timeLabel.fontSize = 6
        timeLabel.zPosition = 100
        
        self.healthLabel = healthLabel
        healthLabel.fontSize = 6
        healthLabel.zPosition = 100
        
        self.gameOverLabel = gameOverLabel
        gameOverLabel.fontSize = 12
        gameOverLabel.zPosition = 100
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
    }
}

