//
//  File.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import Foundation
import SpriteKit

struct CTGameInfo {
    var score = 0
    var scoreIncrementAmount = 1
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    
    init(score: Int = 0, scoreIncrementAmount: Int = 1, scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")) {
        self.score = score
        self.scoreIncrementAmount = scoreIncrementAmount
        
        self.scoreLabel = scoreLabel
        scoreLabel.text = String(self.score)
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: 100, y: 400) // Adjust as needed
    }
    
    mutating func updateScore(deltaTime seconds: TimeInterval)
    {
        self.score += self.scoreIncrementAmount
        self.scoreLabel.text = String(self.score)
//        print("seconds: " + String(seconds))
    }
}

