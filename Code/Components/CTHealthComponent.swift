//
//  CTHealthComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/28/24.
//

import GameplayKit
import SpriteKit
import AVFAudio

class CTHealthComponent: GKComponent {
    let car: SKSpriteNode
    weak var gameScene: CTGameScene?
    var explosionSound: AVAudioPlayer?
    
    init(carNode: SKSpriteNode) {
        self.car = carNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
    
    func applyDeath(){
        
        // have a more drastic death effect later
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let scale = SKAction.scale(by: 1.1, duration: 0.1)
        
        self.car.run(scale)
        self.car.run(fadeOut){
            self.explode()
            self.car.removeFromParent()
        }
    }
    func explode() {
        guard let gameScene else { return }
        playExplosionSound()
        if let explosion = SKEmitterNode(fileNamed: "CTCarExplosion") {
            explosion.position = car.position
            explosion.particleSize = CGSize(width: 70.0, height: 70.0)
            gameScene.addChild(explosion)

            // Remove the emitter after 3 seconds
            let wait = SKAction.wait(forDuration: 3.0)
            let reduce_emmission = SKAction.run {
                explosion.particleBirthRate = 0
            }
            let wait2 = SKAction.wait(forDuration: 1.0)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, reduce_emmission, wait2, remove]))
        }
    }
    
    func playExplosionSound() {
        // Load the explosion sound
        if let explosionSoundURL = Bundle.main.url(forResource: "explosion", withExtension: "mp3") {
            do {
                explosionSound = try AVAudioPlayer(contentsOf: explosionSoundURL)
                explosionSound?.play()
            } catch {
                print("Error loading explosion sound: \(error)")
            }
        }
    }

    // TODO: set appearance accodring to health
    
}
