//
//  CTFuelNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/6/24.
//

import SpriteKit

class CTFuelNode: SKSpriteNode {
    
    init(imageNamed: String, nodeSize: CGSize){
        let texture = SKTexture(imageNamed: imageNamed)
        texture.filteringMode = .nearest
        
        super.init(texture: texture, color: .clear, size: nodeSize)
        zPosition = 10
        enablePhysics()
        wave()
        
//        let pointLight = SKLightNode()
//        pointLight.categoryBitMask = 1 // Set a category for the light
//        pointLight.position = self.position // Position the light
//        pointLight.lightColor = .red // Color of the light
//        pointLight.falloff = 5.0
////        pointLight.ambientColor = .gray // Ambient light color
////        pointLight.shadowColor = .black // Color of the shadows
//        scene?.addChild(pointLight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not found!")
    }
    
    func wave(amplitude: CGFloat = 1, frequency: CGFloat = 1, duration: CGFloat = 1.0) {
            let steps = 100
            let stepDuration = duration / CGFloat(steps)
            
            var actions: [SKAction] = []
            
            for i in 0...steps {
                // Calculate the x and y offset for the current step
                let x = CGFloat(i) / CGFloat(steps) * amplitude * 2 * .pi * frequency
                let y = sin(x) * amplitude * 0.2

                // Move the node by the calculated offsets
                let move = SKAction.moveBy(x: amplitude / CGFloat(steps), y: y, duration: stepDuration)
                actions.append(move)
            }

            // Combine the actions into a sequence
            let waveSequence = SKAction.sequence(actions)

            // Repeat the wave sequence forever
            let sinusoidalAction = SKAction.repeatForever(waveSequence)
            self.run(sinusoidalAction)
        }
    
    func enablePhysics(){
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CTPhysicsCategory.fuel
        self.physicsBody?.contactTestBitMask = CTPhysicsCategory.car
        self.physicsBody?.collisionBitMask = CTPhysicsCategory.none
    }
    
    
    
}
