//
//  Food.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import Foundation
import SwiftData

@Model
final class Food {
    
    var timestamp: Date
    var name: String
    var protein: Int
    var fat: Int
    var glycemicIndex: glycemicIndex
    var dairy: Bool
    
    init(timestamp: Date, name: String, protein: Int, fat: Int, glycemicIndex: glycemicIndex, dairy: Bool) {
        self.timestamp = timestamp
        self.name = name
        self.protein = protein
        self.fat = fat
        self.glycemicIndex = glycemicIndex
        self.dairy = dairy
    }
    
}

enum glycemicIndex {
    case low, medium, high
}
