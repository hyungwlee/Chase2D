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
    var score = 0
    let SCORE_INCREMENT_AMOUNT = 1
    let FREQUENCY_CHANGE_THRESHHOLD = 5 //seconds
    var scoreChangeFrequency = 1.0
    
    var seconds = 0.0
    var pastValue = ProcessInfo.processInfo.systemUptime
    
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var timeLabel = SKLabelNode(fontNamed: "Arial")
    var healthLabel = SKLabelNode(fontNamed: "Arial")
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")/*, currentState: GKState*/) {
        self.score = score
        
        self.scoreLabel = scoreLabel
        scoreLabel.fontSize = 12
        scoreLabel.zPosition = 100
        
        self.timeLabel = timeLabel
        timeLabel.fontSize = 12
        timeLabel.zPosition = 100
        
        self.healthLabel = healthLabel
        healthLabel.fontSize = 12
        healthLabel.zPosition = 100
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

