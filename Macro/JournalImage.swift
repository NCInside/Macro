//
//  JournalImage.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 07/11/24.
//

import Foundation
import SwiftData

@Model
final class JournalImage: Identifiable {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    @Attribute(.externalStorage) var image: Data? 
    var isBreakout: Bool
    var isMenstrual: Bool
    var notes: String?
    
    init(id: UUID = UUID(), timestamp: Date, image: Data? = nil, isBreakout: Bool, isMenstrual: Bool, notes: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.image = image
        self.isBreakout = isBreakout
        self.isMenstrual = isMenstrual
        self.notes = notes
    }
}

