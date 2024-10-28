//
//  CTGameScene.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/26/24.
//

import SpriteKit

class CTGameScene: SKScene {
    weak var context: CTGameContext?
    
    var box: CTBoxNode?
    
    init (context: CTGameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }
    
    required init?(coder aDcoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard let context else {return}
        prepareGameContext()
        prepareStartNodes()
        
        context.stateMachine?.enter(CTGameIdleState.self)
    }
    
    func prepareGameContext() {
        guard let context else {return}
        
        context.scene = self
        context.updateLayoutInfo(withScreenSize: size)
        context.configureStates()
    }
    
    func prepareStartNodes() {
        guard let context else {return}
        let center = CGPoint(x: size.width / 2.0 - context.layoutInfo.boxSize.width / 2.0, y: size.height / 2.0)
        let box = CTBoxNode()
        box.setup(screenSize: size, layoutInfo: context.layoutInfo)
        box.position = center
        addChild(box)
        self.box = box
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouchMoved(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context?.stateMachine?.currentState as? CTGameIdleState else {
            return
        }
        state.handleTouchEnded(touch)
    }
}
