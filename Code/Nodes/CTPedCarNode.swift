//
//  CTPedCarNode.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/3/24.
//

import SpriteKit
class CTPedCarNode: CTCarNode {
    
    let CHECKPOINT_RADIUS_SQUARED = 1000.0
 
    struct PointPairs {
        var start: CGPoint
        var distance: CGFloat
        var angle: CGFloat
    }
   
    var rays: Dictionary<String, PointPairs>
    var isDetectingObstacle: Bool = false
    var currentTarget: CGPoint = CGPoint(x: 0, y: 0)
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
        
        let angle = CGFloat(GLKMathRadiansToDegrees(Float(calculateAngle(pointA: self.position, pointB: target))))
        // since the car is facing vertical up we add a 90
        let carForwardAngle = CGFloat(GLKMathRadiansToDegrees(Float(zRotation)) + 90)
        
        
        var finalAngle = (carForwardAngle - angle).truncatingRemainder(dividingBy: 360)
        finalAngle = finalAngle > 180 ? 360 - (angle + finalAngle) : finalAngle
        print(finalAngle)
        
        // TODO: make some changes here
        if finalAngle > 10 {
            steer(moveDirection: 0.8)
        } else if finalAngle < -10 {
            steer(moveDirection: -0.8)
        } else {
            steer(moveDirection: 0.0)
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
            
            // debug purposes
//            
//             let visibleRay = CGMutablePath()
//             visibleRay.move(to: rayStart)
//             visibleRay.addLine(to: rayEnd)
//             visibleRay.closeSubpath()
//                 
//             if(!raysAdded) {
//                 print(ray.key)
//                 let line = SKShapeNode(path: visibleRay)
//                 line.name = "rayLine" + ray.key
//                 line.strokeColor = .green
//                 line.fillColor = .green
//
//                 rayAddCount += 1
//                 scene?.addChild(line)
//                 if rayAddCount == self.rays.count {
//                     raysAdded = true
//                 }
//             } else {
//                 let currentLine = scene?.childNode(withName: "rayLine" + ray.key) as? SKShapeNode
//                 currentLine?.path = visibleRay
//             }

        }
    }
    
    
}
