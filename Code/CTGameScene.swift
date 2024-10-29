//  CTGameScene.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/26/24.
//

import SpriteKit
import GameplayKit

class CTGameScene: SKScene {
    weak var context: CTGameContext?
    
    var playerCarNode: CTCarNode?
    let worldNode = CTWorldNode()
    let cameraNode = SKCameraNode()
    
    init(context: CTGameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else {
            return
        }
        
        worldNode.setup(screenSize: size)
        worldNode.zPosition = 0
        addChild(worldNode)
        
        cameraNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        addChild(cameraNode)
        camera = cameraNode
        
        let zoomInAction = SKAction.scale(to: 0.3, duration: 0.2)
        cameraNode.run(zoomInAction)
        
        prepareGameContext()
        prepareStartNodes()
        
        context.stateMachine?.enter(CTGameIdleState.self)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        context?.stateMachine?.update(deltaTime: currentTime)
    }
    
    func prepareGameContext(){
    
        guard let context else {
            return
        }

        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {
            return
        }
        let center = CGPoint(x: size.width / 2.0 - context.layoutInfo.playerCarSize.width / 2.0,
                             y: size.height / 2.0)
        let car = CTCarNode()
//        car.setup(screenSize: size, layoutInfo: context.layoutInfo)
        car.position = center
        addChild(car)
        self.playerCarNode = car
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouch(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouchEnded(touch)
    }
}
