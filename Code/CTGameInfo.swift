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
//    var gameOver = false
//    var stateMachine: GKStateMachine?
    
    // player health and player speed to be implemented later on gameInfo
    // implemented individually now
    var playerHealth = 100
    var playerSpeed = 1300
    
    
    // gameplay speed
    var gameplaySpeed = 1
    
    var score = 0
    var scoreIncrementAmount = 1
    let scoreChangeThreshold = 5
    
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var timeLabel = SKLabelNode(fontNamed: "Arial")
    
    var storedSecond = 0
    var secondPassed = false
    var numSecondsPassed = 0
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")) {
        self.score = score
        self.scoreIncrementAmount = scoreIncrementAmount
        
        self.scoreLabel = scoreLabel
//        scoreLabel.text = String(self.score)
        scoreLabel.fontSize = 12
        scoreLabel.zPosition = 100
//        scoreLabel.position = CGPoint(x: 100, y: 400) // Adjust as needed
        
        self.timeLabel = timeLabel
        timeLabel.fontSize = 12
        timeLabel.zPosition = 100
    }
    
    mutating func updateScore(deltaTime seconds: TimeInterval)
    {
//        if stateMachine?.currentState is CTGameOverState
//        {
//            gameOver = true
//        }
//        if gameOver
//        {
//            return
//        }
//        guard stateMachine?.currentState is CTGameIdleState else
//        {
//            return
//        }
        
        var tempSeconds = seconds
        tempSeconds.round(.down)
     
        timeLabel.text = "Time: " + String(numSecondsPassed)
        
        if ((Int(tempSeconds) - storedSecond) >= 1)
        {
            secondPassed = true
            numSecondsPassed += 1
            score += scoreIncrementAmount
            scoreLabel.text = "Score: " + String(score)
    //        print("seconds: " + String(seconds))
        }
        else
        {
            secondPassed = false
        }
        storedSecond = Int(tempSeconds)
        
//        if (((score % scoreChangeThreshold) == 0) && secondPassed)
//        {
//            scoreIncrementAmount = scoreIncrementAmount - (scoreIncrementAmount % 5)
//            scoreIncrementAmount += 5
//        }
        if (((numSecondsPassed % scoreChangeThreshold) == 0) && secondPassed)
        {
            scoreIncrementAmount = scoreIncrementAmount - (scoreIncrementAmount % 5)
            scoreIncrementAmount += 5
        }
    }
}

