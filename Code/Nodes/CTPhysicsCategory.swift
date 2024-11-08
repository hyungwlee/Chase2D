//
//  CTPhysicsCategory.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/2/24.
//

import Foundation

struct CTPhysicsCategory {
    static let car: UInt32                  = 0b1 << 0
    static let building: UInt32             = 0b1 << 1
    static let enemy: UInt32                = 0b1 << 2
    static let ped: UInt32                  = 0b1 << 3
}
