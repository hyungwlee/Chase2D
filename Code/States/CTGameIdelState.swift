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
//    var gameInfo: CTGameInfo?
    var moveDirection: CGFloat = 0.0
    var isTouchingSingle: Bool = false
    var isTouchingDouble: Bool = false
    var touchLocations: Array<CGPoint> = []
    var driveDir = CTCarNode.driveDir.forward
    
    init(scene: CTGameScene, context: CTGameContext) {
        self.scene = scene
        self.context = context
//        self.gameInfo = gameInfo
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
        scene.playerCarNode?.drive(driveDir: self.driveDir)
        
        if(self.touchLocations != []){
            if(isTouchingDouble){
                
            }
            else if(isTouchingSingle){
                self.moveDirection = self.touchLocations[0].x < scene.frame.midX ? -1.0 : 1.0
            }
        }
        scene.playerCarNode?.steer(moveDirection: self.moveDirection)
        
    }
       
    func handleTouchStart(_ touches: Set<UITouch>) {
        guard let scene, let context else { return }
        isTouchingSingle = false
        isTouchingDouble = false
         
        let loc = touches.first?.location(in: scene.view)
        
        
        // this code is for emulator only
        if(loc?.y ?? 0.0 > (scene.frame.height - 100)){
            isTouchingDouble = true
            self.driveDir = CTCarNode.driveDir.backward
            self.moveDirection = -1.0
            for touch in touches{
                self.touchLocations.append(touch.location(in: scene.view))
                return
            }
        }else if(touches.count == 1){
            isTouchingSingle = true
            self.driveDir = CTCarNode.driveDir.forward
            self.touchLocations.append((touches.first?.location(in: scene.view))!)
        }
        
//        if(touches.count > 1){
//            isTouchingDouble = true
//            for touch in touches{
//                self.touchLocations?.append(touch.location(in: scene.view))
//            }
//        }else if(touches.count == 1){
//            isTouchingSingle = true
//            self.touchLocations?.append((touches.first?.location(in: scene.view))!)
//        }
    }
    
    func handleTouchEnded(_ touch: UITouch) {
        isTouchingSingle = false
        isTouchingDouble = false
        self.touchLocations = []
        self.moveDirection = 0
        self.driveDir = CTCarNode.driveDir.forward
    }
    
    func handleCameraMovement() {
        let targetPosition = CGPoint(x: scene?.playerCarNode?.position.x ?? 0.0, y: scene?.playerCarNode?.position.y ?? 0.0)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.1)
        scene?.cameraNode?.run(moveAction)
    }
    
}
