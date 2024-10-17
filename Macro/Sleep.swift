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
    var duration: Int
    var start: Date
    var end: Date
    
    init(timestamp: Date, duration: Int, start: Date, end: Date) {
        self.timestamp = timestamp
        self.duration = duration
        self.start = start
        self.end = end
    }
    
}
