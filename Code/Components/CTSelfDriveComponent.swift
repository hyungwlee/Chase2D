//
//  CTSelfDriveComponent.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/12/24.
//


import GameplayKit
import SpriteKit

class CTSelfDrivingComponent: GKComponent {
    
    struct PointPairs {
        var start: CGPoint
        var distance: CGFloat
        var angle: CGFloat
    }
   
    var rays: Dictionary<String, PointPairs>
    var isDetectingObstacle: Bool = false
    let ramDecider = GKRandomDistribution(lowestValue: 0, highestValue: 1).nextInt()
    
    let carNode: SKSpriteNode
   
    enum driveDir {
        case forward
        case backward
        case none
    }
    
    init(carNode: SKSpriteNode) {
        self.carNode = carNode
        self.rays  = [
            "Left" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 20, angle: 120),
            "Right" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 20, angle: 60),
            "FarRight" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 20, angle: 30),
            "FarLeft" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 20, angle: 150),
            "Up" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 20, angle: 90),
        ]
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    func follow(target: CGPoint){
        if(isDetectingObstacle) { return }
        
        let angleToTarget = atan2(target.y - self.carNode.position.y, target.x - self.carNode.position.x)
                
        // Calculate the shortest angle difference
        var angleDifference = angleToTarget - self.carNode.zRotation + .pi / 2.0
        
        if angleDifference > .pi {
            angleDifference -= 2 * .pi
        } else if angleDifference < -.pi {
            angleDifference += 2 * .pi
        }
        
        if let steeringComponent = entity?.component(ofType: CTSteeringComponent.self){
            if angleDifference > 0.25 {
                steeringComponent.steer(moveDirection: 1.0) // Steer right
             } else if angleDifference < -0.25 {
                 steeringComponent.steer(moveDirection: -1.0) // Steer left
             } else {
                 steeringComponent.steer(moveDirection: 0.0) // Go straight if close enough to target angle
             }
        }
        
    }
   
    func avoidObstacles(){
        
        let distance = 15.0
        
        for ray in self.rays {
            let theta = CGFloat(GLKMathDegreesToRadians(Float(ray.value.angle)))
            let rayStart = CGPoint(x: self.carNode.position.x + 0, y: self.carNode.position.y)
            let rayEnd = CGPoint(x: rayStart.x + distance * cos(theta + self.carNode.zRotation),
                                 y: rayStart.y + distance * sin(theta + self.carNode.zRotation))
            
            
            let body = self.carNode.scene?.physicsWorld.body(alongRayStart: rayStart, end: rayEnd)
            
           
            let drivingComponent = entity?.component(ofType: CTDrivingComponent.self)
            
            if let steeringComponent = entity?.component(ofType: CTSteeringComponent.self){
                if(body?.categoryBitMask == CTPhysicsCategory.building || body?.categoryBitMask == CTPhysicsCategory.car){
                    isDetectingObstacle = true
                    switch(ray.key){
                    case "Right":
                        steeringComponent.steer(moveDirection: -1.0)
                        break;
                    case "Left":
                        steeringComponent.steer(moveDirection: 1.0)
                        break;
                    case "FarLeft":
                        steeringComponent.steer(moveDirection: 0.5)
                        break;
                    case "FarRight":
                        steeringComponent.steer(moveDirection: -0.5)
                        break;
                    case "Up":
                        steeringComponent.steer(moveDirection: ramDecider == 0 ? -1.0 : 1.0)
                        if(body?.categoryBitMask == CTPhysicsCategory.car){
                            if(self.carNode.name == "cop"){
                                drivingComponent?.ram()
                            }
                        }
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
        
        func squareMagnitude(velocity:CGVector?) -> CGFloat {
            guard let velocity else {return 0}
            return velocity.dx * velocity.dx + velocity.dy * velocity.dy
        }
        
    }
}




