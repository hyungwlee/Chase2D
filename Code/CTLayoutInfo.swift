//
//  CTLayoutInfo.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import Foundation
import UIKit

struct CTLayoutInfo{
//    screenSize dimensions (in points): 402 x 874
    
    var screenSize: CGSize = .zero
    var playerCarSize: CGSize = .init(width: 5.2, height: 12.8)
    let copCarSize: CGSize = .init(width: 5.2, height: 12.8)
    let copTruckSize: CGSize = .init(width: 6, height: 15)
    let copTankSize: CGSize = .init(width: 20, height: 35)
    let powerUpSize: CGSize = .init(width: 5.0, height: 5.0)
    let bulletSize: CGSize = .init(width: 2.0, height: 2.0)
    
    var healthIndicatorSize: CGSize = .init(width: 31, height: 31)
    var speedometerSize: CGSize = .init(width: 124, height: 31)
    var speedometerBackgroundSize: CGSize = .init(width: 124, height: 31)
}
