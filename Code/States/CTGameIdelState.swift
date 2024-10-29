//
//  CTGameIdelState.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import GameplayKit

class CTGameIdleState: GKState {
    weak var scene: CTGameScene?
    weak var context: CTGameContext?
    var deltaTime = 0.0
    
    init(scene: CTGameScene, context: CTGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        print("did enter idle state")
   }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.deltaTime = seconds
       
        handleCameraMovement()
        handleCarMovementSetup()
    }
       
    func handleTouch(_ touch: UITouch) {
        guard let scene, let context else { return }
        print("touched \(touch)")
        let touchLocation = touch.location(in: scene)
        let newCarPos = CGPoint(x: touchLocation.x - context.layoutInfo.playerCarSize.width / 2.0,
                                y: touchLocation.y - context.layoutInfo.playerCarSize.height / 2.0)
        scene.playerCarNode?.position = newCarPos
    }
    
    func handleTouchEnded(_ touch: UITouch) {
        print("touched ended \(touch)")
    }
    
    func handleCameraMovement() {
        let targetPosition = CGPoint(x: scene?.playerCarNode?.position.x ?? 0.0, y: scene?.playerCarNode?.position.y ?? 0.0)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.1)
        scene?.cameraNode.run(moveAction)
    }
    
    func handleCarMovementSetup(){
       
        let directionX = sin(scene?.playerCarNode!.zRotation ?? 0.0)
        let directionY = cos(scene?.playerCarNode?.zRotation ?? 0.0)
        let moveForce: CGFloat = self.deltaTime * 0.05
        
        let force = CGVector(dx: directionX * moveForce, dy: directionY * moveForce)
        scene?.playerCarNode?.physicsBody?.applyForce(force)
        
    }
    
}
