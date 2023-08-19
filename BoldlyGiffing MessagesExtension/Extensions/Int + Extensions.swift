//
//  Int + Extensions.swift
//  BoldyGiffing MessagesExtension
//
//  Created by Aaron Williams on 2017-07-10.
//  Copyright © 2017 Sweet Software. All rights reserved.
//

import Foundation

public extension Int {
    /**
     * Returns a random integer between 0 and n-1.
     */
    static func random(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
}
