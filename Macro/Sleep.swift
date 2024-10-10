//
//  Sleep.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import Foundation
import SwiftData

@Model
final class Sleep {
    
    var timestamp: Date
    var duration: Double
    
    init(timestamp: Date, duration: Double) {
        self.timestamp = timestamp
        self.duration = duration
    }
    
}
