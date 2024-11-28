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
    var gameScene: CTGameScene
    var layoutInfo: CTLayoutInfo
    
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
    
//    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), timeLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), healthLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"), gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial"))
//    {
//        self.score = score
//    }
        
    mutating func setGameOver(val: Bool)
    {
        gameOver = val
    }
    
    mutating func updateTime(phoneRuntime: TimeInterval)
    {
        seconds += (phoneRuntime - pastValue)
        pastValue = phoneRuntime
    }
    
    mutating func updateScore()
    {
        let cleanSeconds = Int(Double(String(format: "%.2f", seconds))! * 100)
        if ((cleanSeconds % Int(scoreChangeFrequency * 100)) == 0)
        {
            score += SCORE_INCREMENT_AMOUNT
        }

        if (((Int(seconds) % FREQUENCY_CHANGE_THRESHHOLD) == 0) && scoreChangeFrequency >= 0.2)
        {
            scoreChangeFrequency -= 0.1
        }
    }
    
    func updateHealthUI()/* -> SKTexture*/
    {
        if (playerHealth > 75)
        {
            gameScene.healthIndicator.texture = SKTexture(imageNamed: "player100")
//            return SKTexture(imageNamed: "player100")
        }
        else if (playerHealth > 50)
        {
            gameScene.healthIndicator.texture = SKTexture(imageNamed: "player75")
//            return SKTexture(imageNamed: "player75")
        }
        else if (playerHealth > 25)
        {
            gameScene.healthIndicator.texture = SKTexture(imageNamed: "player50")
//            return SKTexture(imageNamed: "player50")
        }
        else if (playerHealth > 0)
        {
            gameScene.healthIndicator.texture = SKTexture(imageNamed: "player25")
//            return SKTexture(imageNamed: "player25")
        }
        else
        {
            gameScene.healthIndicator.isHidden = true
        }
    }
    
    func updateSpeed(speed: CGFloat) -> CGFloat
    {
        let percentage = speed / 200
        let adjWidth = layoutInfo.screenSize.width
        let output = (adjWidth * percentage)
        
        return (output - adjWidth)
    }
}

