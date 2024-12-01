//
//  CTLayoutInfo.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 10/28/24.
//

import Foundation

struct CTLayoutInfo{
    let screenSize: CGSize
    let playerCarSize: CGSize = .init(width: 5.2, height: 12.8)
    let copCarSize: CGSize = .init(width: 5.2, height: 12.8)
    let copTruckSize: CGSize = .init(width: 6, height: 15)
    let copTankSize: CGSize = .init(width: 15, height: 35)
    let powerUpSize: CGSize = .init(width: 10.0, height: 10.0)
    let bulletSize: CGSize = .init(width: 2.0, height: 4.0)
}
