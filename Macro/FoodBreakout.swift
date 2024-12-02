//
//  FoodBreakout.swift
//  Macro
//
//  Created by WanSen on 29/11/24.
//

import Foundation
import SwiftData

@Model
final class FoodBreakout: Identifiable {
    @Attribute(.unique) var id: UUID
    var foodName: String
    var gramPortion: Int
    var breakoutDate: Date

    init(id: UUID = UUID(), foodName: String, gramPortion: Int, breakoutDate: Date) {
        self.id = id
        self.foodName = foodName
        self.gramPortion = gramPortion
        self.breakoutDate = breakoutDate
    }
}
