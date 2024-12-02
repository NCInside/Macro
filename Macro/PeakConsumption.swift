//
//  PeakConsumption.swift
//  Macro
//
//  Created by WanSen on 02/12/24.
//

import Foundation
import SwiftData

@Model
final class PeakConsumption: ObservableObject {
    @Attribute(.unique) var id: UUID
    var highestGlycemicIndex: Int
    var highestFat: Double
    var highestDairy: Int
    var previousHighestGlycemicIndex: Int
    var previousHighestFat: Double
    var previousHighestDairy: Int
    
    init(
        id: UUID = UUID(),
        highestGlycemicIndex: Int = 0,
        highestFat: Double = 0.0,
        highestDairy: Int = 0,
        previousHighestGlycemicIndex: Int = 0,
        previousHighestFat: Double = 0.0,
        previousHighestDairy: Int = 0
    ) {
        self.id = id
        self.highestGlycemicIndex = highestGlycemicIndex
        self.highestFat = highestFat
        self.highestDairy = highestDairy
        self.previousHighestGlycemicIndex = previousHighestGlycemicIndex
        self.previousHighestFat = previousHighestFat
        self.previousHighestDairy = previousHighestDairy
    }
}
