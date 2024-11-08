//
//  JournalImageViewModel.swift
//  Macro
//
//  Created by WanSen on 08/11/24.
//

import SwiftUI
import SwiftData
import UIKit

@MainActor
class JournalImageViewModel: ObservableObject {
    @Published var journalImages: [JournalImage] = []
        public let context: ModelContext // Change context to public
        
        init(context: ModelContext) {
            self.context = context
            fetchJournalImages()
        }
    func addDummyData() {
            let calendar = Calendar.current
            let today = Date()
            
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!

            // Add dummy for yesterday
            addJournalImage(
                timestamp: yesterday,
                image: nil,
                isBreakout: true,
                isMenstrual: false,
                notes: "Dummy entry for yesterday."
            )
            
            // Add dummy for the day before yesterday
            addJournalImage(
                timestamp: dayBeforeYesterday,
                image: nil,
                isBreakout: false,
                isMenstrual: true,
                notes: "Dummy entry for the day before yesterday."
            )
            
            // Refresh the view
            fetchJournalImages()
        }

    // Fetch all JournalImage entries using FetchDescriptor
    func fetchJournalImages(for date: Date? = nil) {
        let descriptor = FetchDescriptor<JournalImage>()
        do {
            let fetchedImages = try context.fetch(descriptor)
            if let date = date {
                // Filter journalImages for the specific date
                let calendar = Calendar.current
                self.journalImages = fetchedImages.filter {
                    calendar.isDate($0.timestamp, inSameDayAs: date)
                }
            } else {
                // Fetch all journal images
                self.journalImages = fetchedImages
            }
        } catch {
            print("Failed to fetch JournalImages: \(error.localizedDescription)")
        }
    }
    
    // Create a new JournalImage entry
    func addJournalImage(timestamp: Date, image: Data?, isBreakout: Bool, isMenstrual: Bool, notes: String? = nil) {
           let newJournalImage = JournalImage(
               timestamp: timestamp,
               image: image,
               isBreakout: isBreakout,
               isMenstrual: isMenstrual,
               notes: notes
           )
           context.insert(newJournalImage)
           
           do {
               try context.save()
               journalImages.append(newJournalImage)
           } catch {
               print("Failed to save JournalImage: \(error.localizedDescription)")
           }
       }
    
    // Update an existing JournalImage entry
    func updateJournalImage(journalImage: JournalImage, newImage: UIImage? = nil, isBreakout: Bool? = nil, isMenstrual: Bool? = nil, notes: String? = nil) {
        if let newImage = newImage, let imageData = newImage.jpegData(compressionQuality: 1.0) {
            journalImage.image = imageData
        }
        
        if let isBreakout = isBreakout {
            journalImage.isBreakout = isBreakout
        }
        
        if let isMenstrual = isMenstrual {
            journalImage.isMenstrual = isMenstrual
        }
        
        if let notes = notes {
            journalImage.notes = notes
        }
        
        do {
            try context.save()
            fetchJournalImages() // Refresh the list after update
        } catch {
            print("Failed to update JournalImage: \(error.localizedDescription)")
        }
    }
    
    // Delete a JournalImage entry
    func deleteJournalImage(journalImage: JournalImage) {
        context.delete(journalImage)
        
        do {
            try context.save()
            if let index = journalImages.firstIndex(of: journalImage) {
                journalImages.remove(at: index)
            }
        } catch {
            print("Failed to delete JournalImage: \(error.localizedDescription)")
        }
    }
}
