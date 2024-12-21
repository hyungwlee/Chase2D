//
//  CTDrivingComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/11/24.
//

import GameplayKit
import SpriteKit
import AVFAudio

class CTDrivingComponent: GKComponent {
    
    let carNode: SKSpriteNode
    var MOVE_FORCE: CGFloat = 1300
    var hasStopped = false
    var isRamming = false
    var maxLateralImpulse: CGFloat = 100.0
    let smokeParticle: SKEmitterNode?
    var driftParticles: [SKEmitterNode] = [] // Drift particle system
    var enableEngineSound: Bool = false
    private var soundSetup = false

    var enginePlayer: AVAudioPlayer?
    var driftPlayer: AVAudioPlayer?
    var isDrifting: Bool = false
   
    enum driveDir {
        case forward
        case backward
        case none
    }
    
    init(carNode: SKSpriteNode, enableSmoke: Bool) {
        self.carNode = carNode
//        self.smokeParticle = CTSmokeParticle()
//        carNode.addChild(smokeParticle)
        
        smokeParticle = SKEmitterNode(fileNamed: "CTCarSmoke")
        smokeParticle?.position = CGPoint(x: 0.0, y: carNode.size.height / 2.0)
        smokeParticle?.particleSize = CGSize(width: 50, height: 50)
        
        if enableSmoke {
           carNode.addChild(smokeParticle!)
       }
        
        let driftParticleSize = CGSize(width: 3, height: 3)
        
        // Initialize the drift particle system
        if let drift1 = SKEmitterNode(fileNamed: "CTDriftParticle") {
            drift1.position = CGPoint(x: (carNode.size.width / 3.0), y: (carNode.size.height / 3.0))
            drift1.particleBirthRate = 0 // Start with disabled particles
            drift1.particleSize = driftParticleSize
            driftParticles.append(drift1)
            carNode.addChild(drift1)
        }
        
        // Initialize the drift particle system
        if let drift2 = SKEmitterNode(fileNamed: "CTDriftParticle") {
            drift2.position = CGPoint(x: -(carNode.size.width / 3.0), y: (carNode.size.height / 3.0))
            drift2.particleBirthRate = 0 // Start with disabled particles
            drift2.particleSize = driftParticleSize
            driftParticles.append(drift2)
            carNode.addChild(drift2)
        }
        
        // Initialize the drift particle system
        if let drift3 = SKEmitterNode(fileNamed: "CTDriftParticle") {
            drift3.position = CGPoint(x: (carNode.size.width / 3.0), y: (carNode.size.height / 3.0))
            drift3.particleBirthRate = 0 // Start with disabled particles
            drift3.particleSize = driftParticleSize
            driftParticles.append(drift3)
            carNode.addChild(drift3)
        }
        
        // Initialize the drift particle system
        if let drift4 = SKEmitterNode(fileNamed: "CTDriftParticle") {
            drift4.position = CGPoint(x: -(carNode.size.width / 3.0), y: -(carNode.size.height / 3.0))
            drift4.particleBirthRate = 0 // Start with disabled particles
            drift4.particleSize = driftParticleSize
            driftParticles.append(drift4)
            carNode.addChild(drift4)
        }
        
        
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    func drive(driveDir: driveDir) {
        guard let physicsBody = carNode.physicsBody else { return }
        
        reduceLateralVelocity()
        if enableEngineSound && !soundSetup {
            playEngineSound()
            playDriftSound()
            soundSetup = true
        }
             
        if carNode.speed < 10
        {
            enginePlayer?.stop()
            driftPlayer?.stop()
        }
       
//        if enableSmoke {
//            smokeParticle.particleSystemUpdate()
//        }
        
        if driveDir == .backward {
            if (physicsBody.velocity.dx * physicsBody.velocity.dx + physicsBody.velocity.dy * physicsBody.velocity.dy) > 700 && !hasStopped {
                self.carNode.physicsBody?.linearDamping = 1.0
                self.carNode.physicsBody?.angularVelocity = 0.0
            } else {
                hasStopped = true
                self.carNode.physicsBody?.linearDamping = 10.0
                let directionX = -sin(self.carNode.zRotation) * MOVE_FORCE * 40
                let directionY = cos(self.carNode.zRotation) * MOVE_FORCE * 40
                let force = CGVector(dx: -2 * directionX, dy: -2 * directionY)
                self.carNode.physicsBody?.applyForce(force)
            }
        } else if driveDir == .forward {
            hasStopped = false
            self.carNode.physicsBody?.linearDamping = 10.0
            
            let directionX = -sin(self.carNode.zRotation) * MOVE_FORCE * 75
            let directionY = cos(self.carNode.zRotation) * MOVE_FORCE * 70
            let force = CGVector(dx: directionX, dy: directionY)
            self.carNode.physicsBody?.applyForce(force)
        }
    }
    
    
    func playEngineSound() {
        // Load the engine running sound from the main bundle
        if let url = Bundle.main.url(forResource: "CT_engine_running", withExtension: "mp3") {
            do {
                enginePlayer = try AVAudioPlayer(contentsOf: url)
                enginePlayer?.numberOfLoops = -1 // Loop indefinitely
                enginePlayer?.volume = 0.2 // Set constant volume
                enginePlayer?.play()
            } catch {
                print("Failed to play engine sound: \(error.localizedDescription)")
            }
        } else {
            print("Engine running sound file not found.")
        }
    }
    
    func playDriftSound() {
        // Load the engine running sound from the main bundle
        if let url = Bundle.main.url(forResource: "CT_drift", withExtension: "mp3") {
            do {
                driftPlayer = try AVAudioPlayer(contentsOf: url)
                driftPlayer?.volume = 0.25 // Set constant volume
            } catch {
                print("Failed to play engine sound: \(error.localizedDescription)")
            }
        } else {
            print("Engine drift sound file not found.")
        }
    }
    
    func reduceLateralVelocity() {
        guard let body = carNode.physicsBody else { return }
        let rightNormal = CGVector(dx: -sin(carNode.zRotation), dy: cos(carNode.zRotation))
        let lateralSpeed = body.velocity.dx * rightNormal.dx + body.velocity.dy * rightNormal.dy
        let lateralImpulse = CGVector(dx: rightNormal.dx * -lateralSpeed, dy: rightNormal.dy * -lateralSpeed)
        let impulseLength = sqrt(pow(lateralImpulse.dx, 2) + pow(lateralImpulse.dy, 2))

        if impulseLength > maxLateralImpulse {
            let factor = maxLateralImpulse / impulseLength
            body.applyImpulse(CGVector(dx: lateralImpulse.dx * factor, dy: lateralImpulse.dy * factor))
            activateDriftParticles(false)
            if driftPlayer?.isPlaying == true {
                driftPlayer?.stop()
            }
        } else {
            body.applyImpulse(lateralImpulse)
            activateDriftParticles(true)
            if driftPlayer?.isPlaying == false {
                driftPlayer?.play()
            }
            
        }
    }
    
    func activateDriftParticles(_ active: Bool) {
        for driftParticle in driftParticles {
            driftParticle.particleBirthRate = active ? 100 : 0 // Enable/disable particles
        }
        
    }
    
    func ram() {
        if isRamming { return }
        // Timer logic for ramming
        let wait = SKAction.wait(forDuration: 0.05)
        let run = SKAction.run {
            self.isRamming = true
            self.MOVE_FORCE = self.MOVE_FORCE * 1.1
        }
        let end = SKAction.run {
            self.MOVE_FORCE = self.MOVE_FORCE / 1.1
        }
        let wait2 = SKAction.wait(forDuration: 2)
        let reset = SKAction.run {
            self.isRamming = false
        }
        
        let sequence = SKAction.sequence([run, wait, end, wait2, reset])
        self.carNode.run(sequence)
    }
}
