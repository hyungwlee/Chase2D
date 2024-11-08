//
//  CTPedCarNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/3/24.
//

import SpriteKit
class CTPedCarNode: CTCarNode {
    
    let CHECKPOINT_RADIUS_SQUARED = 500.0
 
    struct PointPairs {
        var start: CGPoint
        var distance: CGFloat
        var angle: CGFloat
    }
   
    var rays: Dictionary<String, PointPairs>
    var isDetectingObstacle: Bool = false
    var currentTarget: CGPoint = CGPoint(x: 100, y: 50)
    var checkPointsList: [SKNode] = []
    var currentTargetIndex = 0
    
    override init(imageNamed: String, size: CGSize){
        // initialize rays
        self.rays  = [
            "Left" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 120),
            "Right" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 10, angle: 60),
            "FarRight" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 2, angle: 30),
            "FarLeft" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 2, angle: 150),
            "Up" : PointPairs(start: CGPoint(x: 0, y: 0), distance: 20, angle: 90),
        ]
        
        super.init(imageNamed: imageNamed, size: size)
        super.enablePhysics()
        
        self.size = size
        texture?.filteringMode = .nearest
        
        self.STEER_IMPULSE = 0.05
        self.MOVE_FORCE = 800
        self.DRIFT_FORCE = 100
        self.DRIFT_VELOCITY_THRESHOLD = 6
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drive(driveDir: CTCarNode.driveDir) {
        super.drive(driveDir: .forward)
        avoidObstacles()
        
        // change currentTarget if the pedCar reaches the checkpoint
        if calculateSquareDistance(pointA: self.position, pointB: currentTarget) < CHECKPOINT_RADIUS_SQUARED{
            currentTargetIndex += 1
            
            currentTargetIndex = currentTargetIndex % (checkPointsList.count - 1)
            currentTarget = checkPointsList[currentTargetIndex].position
            let sq = SKShapeNode(rect: CGRect(x: currentTarget.x, y: currentTarget.y, width: 1, height: 1))
            sq.fillColor = .red
            scene?.addChild(sq)
           
           
        }
        follow(target: currentTarget)
    }
    
    func follow(target: CGPoint){
        if(isDetectingObstacle) { return }
        
        let angleToTarget = atan2(target.y - position.y, target.x - position.x)
                
        // Calculate the shortest angle difference
        var angleDifference = angleToTarget - zRotation + .pi / 2.0
        
        if angleDifference > .pi {
            angleDifference -= 2 * .pi
        } else if angleDifference < -.pi {
            angleDifference += 2 * .pi
        }
        
        if angleDifference > 0.1 {
             steer(moveDirection: 1.0) // Steer right
         } else if angleDifference < -0.1 {
             steer(moveDirection: -1.0) // Steer left
         } else {
             steer(moveDirection: 0.0) // Go straight if close enough to target angle
         }
    }
   
    func avoidObstacles(){
        
        let distance = 15.0
        
        for ray in self.rays {
            let theta = CGFloat(GLKMathDegreesToRadians(Float(ray.value.angle)))
            let rayStart = CGPoint(x: self.position.x + 0, y: self.position.y)
            let rayEnd = CGPoint(x: rayStart.x + distance * cos(theta + self.zRotation),
                                 y: rayStart.y + distance * sin(theta + self.zRotation))
        
           
            let body = scene?.physicsWorld.body(alongRayStart: rayStart, end: rayEnd)
            if(body?.categoryBitMask == CTPhysicsCategory.collidableObstacle){
                isDetectingObstacle = true
                switch(ray.key){
                    case "Right":
                        self.steer(moveDirection: -1.0)
                        print("going left")
                        break;
                    case "Left":
                        self.steer(moveDirection: 1.0)
                        print("going right")
                        break;
                    case "FarLeft":
                        self.steer(moveDirection: 0.5)
                        print("going right")
                        break;
                    case "FarRight":
                        self.steer(moveDirection: -0.5)
                        print("going left")
                        break;
                    case "Up":
                        self.steer(moveDirection: -1.0)
                        print("going right")
                        break;
                    default:
                        self.steer(moveDirection: 0.0)
                        break;
                    }
            }else{
                isDetectingObstacle = false
            }
        }
    }
    
    
}
