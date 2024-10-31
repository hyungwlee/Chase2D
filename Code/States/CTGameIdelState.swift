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
    var moveDirection: CGFloat = 0.0
    var isTouching: Bool = false
    var touchLocation: CGPoint?
    
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
        guard let scene else { return }
       
        handleCameraMovement()
        scene.playerCarNode?.drive()
        
        if(self.touchLocation != nil && isTouching == true){
            self.moveDirection = self.touchLocation?.x ?? 0.0 < scene.frame.midX ? -1.0 : 1.0
        }
        scene.playerCarNode?.steer(moveDirection: self.moveDirection)
        
    }
       
    func handleTouchStart(_ touch: UITouch) {
        guard let scene, let context else { return }
        print("touched \(touch)")
        self.touchLocation = touch.location(in: scene.view)
        
        
        isTouching = true
    }
    
    func handleTouchEnded(_ touch: UITouch) {
        print("touched ended \(touch)")
        isTouching = false
        self.moveDirection = 0
    }
    
    func handleCameraMovement() {
        let targetPosition = CGPoint(x: scene?.playerCarNode?.position.x ?? 0.0, y: scene?.playerCarNode?.position.y ?? 0.0)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.1)
        scene?.cameraNode.run(moveAction)
    }
    
}
