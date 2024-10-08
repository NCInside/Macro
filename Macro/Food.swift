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
    
    var name: String
    var protein: Int
    var fat: Int
    var glycemicIndex: Int
    var dairy: Bool
    
    init(name: String, protein: Int, fat: Int, glycemicIndex: Int, dairy: Bool) {
        self.name = name
        self.protein = protein
        self.fat = fat
        self.glycemicIndex = glycemicIndex
        self.dairy = dairy
    }
    
}
