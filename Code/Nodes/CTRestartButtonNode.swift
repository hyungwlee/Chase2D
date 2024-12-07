//
//  CTRestartButtonNode.swift
//  Chase2D
//
//  Created by James Calder on 12/7/24.
//
import SpriteKit

class CTRestartButtonNode: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
//    var onTap: (() -> Void)? // Closure to handle the button tap
    var tapped = false

    init(text: String, size: CGSize, backgroundColor: UIColor) {
        background = SKShapeNode(rectOf: size, cornerRadius: 8)
        background.fillColor = backgroundColor
        background.strokeColor = .clear
        
        label = SKLabelNode(text: text)
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center

        super.init()

        addChild(background)
        addChild(label)
        
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        onTap?() // Trigger the tap action
        tapped = true
    }
}
