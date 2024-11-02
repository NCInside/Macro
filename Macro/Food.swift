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
    var cookingTechnique: [String]
    var fat: Double
    var glycemicIndex: glycemicIndex
    var dairy: Bool
    var gramPortion: Int
    
    init(timestamp: Date, name: String, cookingTechnique: [String], fat: Double, glycemicIndex: glycemicIndex, dairy: Bool, gramPortion: Int) {
        self.timestamp = timestamp
        self.name = name
        self.cookingTechnique = cookingTechnique
        self.fat = fat
        self.glycemicIndex = glycemicIndex
        self.dairy = dairy
        self.gramPortion = gramPortion
    }
    
}

enum glycemicIndex: Int, Codable {
    case low = 0
    case medium = 1
    case high = 2
}
