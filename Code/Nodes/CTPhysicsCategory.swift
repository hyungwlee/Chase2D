//
//  CTPhysicsCategory.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/2/24.
//

import Foundation

struct CTPhysicsCategory {
    static let none: UInt32                 = 0
    static let car: UInt32                  = 0b1 << 0
    static let building: UInt32             = 0b1 << 1
    static let copCar: UInt32               = 0b1 << 2
    static let copTruck: UInt32             = 0b1 << 3
    static let copTank: UInt32              = 0b1 << 4
    static let ped: UInt32                  = 0b1 << 5
    static let powerup: UInt32              = 0b1 << 6
    static let copBullet: UInt32               = 0b1 << 7
    static let playerBullet: UInt32               = 0b1 << 7
}
