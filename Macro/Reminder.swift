import SwiftData
import Foundation

@Model
final class Reminder: Identifiable {
    @Attribute(.unique) var id: UUID
    var clinicName: String
    var visitDate: Date

    init(id: UUID = UUID(), clinicName: String, visitDate: Date) {
        self.id = id
        self.clinicName = clinicName
        self.visitDate = visitDate
    }
}
