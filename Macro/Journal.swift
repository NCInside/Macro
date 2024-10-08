//
//  Journal.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import Foundation
import SwiftData

@Model
final class Journal {
    
    var timestamp: Date
    var foods: [Food]
    var sleep: Sleep
    
    init(timestamp: Date, foods: [Food], sleep: Sleep) {
        self.timestamp = timestamp
        self.foods = foods
        self.sleep = sleep
    }
    
}
