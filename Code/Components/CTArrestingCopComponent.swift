//
//  CTArrestingCopComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/5/24.
//

import GameplayKit

class CTArrestingCopComponent: GKComponent {
    let carNode: SKSpriteNode
    weak var copEntity: CTCopEntity?
    weak var gameScene: CTGameScene?
    var distancewithPlayer = 100.0
    var spawned = false
    weak var parentEntity: GKEntity?
    
    init(carNode: DriveableNode, entity: GKEntity) {
        self.carNode = carNode
        self.parentEntity = entity
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder not implementd")
    }
    
    func update(){
        guard let gameScene else { return }
        if let playerCarNode = gameScene.playerCarEntity?.carNode {
            let speed = gameScene.playerSpeed
            let distance = hypot(abs(carNode.position.x - playerCarNode.position.x),
                                 abs(carNode.position.y - playerCarNode.position.y))
            
//            print(speed, distance)
            if(speed < 3 && distance < 15){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) //it takes 2 seconds for cop to decide to get out of car
                {
                    if (speed < 3 && distance < 15 && !self.spawned)
                    {
                        self.spawnCop()
                        self.startArrest(playerPosition: playerCarNode.position)
                        self.spawned = true
                    }
                }
                
            }
        }
    }
    
    func startArrest (playerPosition: CGPoint) {
        guard let gameScene else { return }
        guard let copEntity else { return }
        
        let oldCollisionBitmask = copEntity.cop.physicsBody?.collisionBitMask ?? CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.copCar | CTPhysicsCategory.copTank | CTPhysicsCategory.copTruck | CTPhysicsCategory.cop
        // timer
        let startArrest = SKAction.run {
            if let drivingComponent = self.entity?.component(ofType: CTDrivingComponent.self){
                drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE / 10000
                self.copEntity?.cop.physicsBody?.collisionBitMask = CTPhysicsCategory.car | CTPhysicsCategory.building | CTPhysicsCategory.ped | CTPhysicsCategory.cop
            }
        }
        let wait = SKAction.wait(forDuration: 0.5)
        let endArrest = SKAction.run{
            self.distancewithPlayer = hypot(abs(copEntity.cop.position.x - playerPosition.x - 2.0), abs(copEntity.cop.position.y - playerPosition.y + 2.0))
            
            if self.distancewithPlayer < 15 && gameScene.playerSpeed < 5 {
                gameScene.gameInfo.gameOver = true
                gameScene.gameInfo.arrestMade()
            }
            if let drivingComponent = self.entity?.component(ofType: CTDrivingComponent.self){
                drivingComponent.MOVE_FORCE = drivingComponent.MOVE_FORCE * 10000
            }
        }
       
        let sequence = SKAction.sequence([startArrest, wait, endArrest])
        self.carNode.run(sequence)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0)
        {
            self.copEntity?.cop.physicsBody?.collisionBitMask = oldCollisionBitmask
        }
    }
    

    func spawnCop(){
        
        guard let copEntity = copEntity,
              let gameScene = gameScene,
              let entity = self.parentEntity else { return }
       
       
        if let steeringComponent = entity.component(ofType: CTSteeringComponent.self) {
            entity.removeComponent(ofType: CTSteeringComponent.self)
        }
        if entity.component(ofType: CTDrivingComponent.self) != nil {
            entity.removeComponent(ofType: CTDrivingComponent.self)
        }
        
        copEntity.cop.position = CGPoint(x: carNode.position.x - 2.0, y: carNode.position.y + 2.0)
        gameScene.addChild(copEntity.cop)
        gameScene.gameInfo.numberOfCops -= 1
        
    }

}
