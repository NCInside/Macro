//
//  Item.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 03/10/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
