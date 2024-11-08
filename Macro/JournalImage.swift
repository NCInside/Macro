//
//  JournalImage.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 07/11/24.
//

import Foundation
import SwiftData

@Model
final class JournalImage {
    
    var timestamp: Date
    @Attribute(.externalStorage)
    var image: Data
    var isBreakout: Bool
    var isMenstrual: Bool
    var notes: String?
    
    init(timestamp: Date, image: Data, isBreakout: Bool, isMenstrual: Bool, notes: String? = nil) {
        self.timestamp = timestamp
        self.image = image
        self.isBreakout = isBreakout
        self.isMenstrual = isMenstrual
        self.notes = notes
    }
    
}
