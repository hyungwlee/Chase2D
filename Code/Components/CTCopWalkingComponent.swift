//
//  CTCopWalkingComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 12/5/24.
//

import SpriteKit

class CTCopWalkingComponent: CTSelfDrivingComponent{
    
    var copEntity: CTCopEntity?
    var newTarget = CGPoint(x: 0.0, y: 0.0)
    
    init(cop: DriveableNode){
        super.init(carNode: cop)
        self.rays  = [
            "Left" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 105),
            "Right" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 75),
            "FarRight" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 45),
            "FarLeft" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 135),
            "Up" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 90),
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func follow(target: CGPoint) {
        
        
        
        newTarget = CGPoint(x: target.x - 2.0, y: target.y + 2.0)
        super.follow(target: newTarget)
    }
    
    
    override func avoidObstacles(){
        
        let distance = 15.0
        
        for ray in self.rays {
            let theta = CGFloat(GLKMathDegreesToRadians(Float(ray.value.angle)))
            let rayStart = CGPoint(x: self.carNode.position.x + 0, y: self.carNode.position.y)
            let rayEnd = CGPoint(x: rayStart.x + distance * cos(theta + self.carNode.zRotation),
                                 y: rayStart.y + distance * sin(theta + self.carNode.zRotation))
            
            
            let body = self.carNode.scene?.physicsWorld.body(alongRayStart: rayStart, end: rayEnd)
            
            if let steeringComponent = entity?.component(ofType: CTSteeringComponent.self){
                if(body?.categoryBitMask == CTPhysicsCategory.building){
                    isDetectingObstacle = true
                    switch(ray.key){
                    case "Right":
                        steeringComponent.steer(moveDirection: -0.25)
                        break;
                    case "Left":
                        steeringComponent.steer(moveDirection: 0.25)
                        break;
                    case "FarLeft":
                        steeringComponent.steer(moveDirection: 0.125)
                        break;
                    case "FarRight":
                        steeringComponent.steer(moveDirection: -0.125)
                        break;
                    case "Up":
                        steeringComponent.steer(moveDirection: ramDecider == 0 ? -0.25 : 0.25)
                        break;
                    default:
                        steeringComponent.steer(moveDirection: 0.0)
                        break;
                    }
                }else{
                    isDetectingObstacle = false
                }
            }
            
        }
        
        
    }
}
