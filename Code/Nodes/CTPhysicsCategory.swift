//
//  CTPhysicsCategory.swift
//  Chase2D
//
//  Created by Roshan Thapa Magar on 11/2/24.
//

import Foundation

struct CTPhysicsCategory {
    static let none: UInt32     = 0
    static let car: UInt32      = 0b1
    static let cop: UInt32      = 0b1 << 1
    static let building: UInt32 = 0b1 << 2
}
