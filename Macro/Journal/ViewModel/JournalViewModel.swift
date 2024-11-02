//
//  JournalViewModel.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import Foundation
import UIKit
import SwiftData

class JournalViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedImage: UIImage?
    @Published var isImagePickerPresented: Bool = false
    @Published var isDietViewPresented: Bool = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    private var healthManager = HealthManager()
    @Published var isDatePickerVisible: Bool = false
    
    var days: [String] {
        return ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
    }
    
    func daysInCurrentWeek() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)!
        var daysOfWeek = [Date]()
        
        for day in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: day, to: weekInterval.start) {
                daysOfWeek.append(dayDate)
            }
        }
        return daysOfWeek
    }
    
    func isSelected(date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    func selectDate(date: Date) {
        selectedDate = date
    }
    
    func getMonthInIndonesian() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: selectedDate)
    }
    
    func presentActionSheet() {
        isImagePickerPresented = true
    }
    
    func fetchSleepData(context: ModelContext, journals: [Journal]) {
        
        if hasEntriesFromDate(entries: journals, date: Date()) == nil {
            
            print("Fetching sleep data...")
            var first: Date = Date()
            var last: Date = Date()
            
            print(first, last)
            healthManager.fetchSleepData { samples in
                DispatchQueue.main.async {
                    guard let samples = samples, !samples.isEmpty else {
                        print("Sample Empty")
                        return
                    }
                    first = samples.first!.endDate
                    last = samples.last!.startDate
                    
                    let sleep: Sleep = Sleep(timestamp: Date(), duration: Int(first.timeIntervalSince(last)))
                    print(sleep.duration)
                    let journal = Journal(timestamp: Date(), foods: [], sleep: sleep)
                    
                    context.insert(journal)
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    func getSleep(journals: [Journal]) -> (hour: String, minute: String) {
        if let journal = hasEntriesFromDate(entries: journals, date: selectedDate) {
            let sleep = journal.sleep
            
            if sleep.duration == 0 {
                return ("0", "0")
            }
            
            let hour: Int = sleep.duration / 3600
            let minute: Int = (sleep.duration % 3600) / 60
            
            let hourString = String(format: "%02d", hour)
            let minuteString = String(format: "%02d", minute)
            
            return (hourString, minuteString)
        }
        
        return ("0", "0")
    }
    
    func calcFat(journals: [Journal]) -> Double {
        var fat: Double = 0
        if let todayJournal = hasEntriesFromDate(entries: journals, date: selectedDate) {
            for food in todayJournal.foods {
                fat += food.fat
            }
        }
        return fat
    }
    
    func calcDairy(journals: [Journal]) -> Int {
        var dairy = 0
        if let todayJournal = hasEntriesFromDate(entries: journals, date: selectedDate) {
            for food in todayJournal.foods {
                dairy += food.dairy ? 1 : 0
            }
        }
        return dairy
    }
    
    func calcGI(journals: [Journal]) -> Int {
        var gi = 0
        if let todayJournal = hasEntriesFromDate(entries: journals, date: selectedDate) {
            for food in todayJournal.foods {
                switch food.glycemicIndex {
                case .low:
                    continue
                case .medium:
                    gi += 1
                case .high:
                    gi += 2
                }
            }
        }
        return gi
    }
    
    func addDiet(context: ModelContext, name: String, entries: [Journal]) {
        
        guard let url = Bundle.main.url(forResource: "NutrisiMakanan", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON")
            return
        }
        
        if let foodItem = foodItems.first(where: { $0.name == name }) {
            
            let food = Food(timestamp: Date(), name: name, cookingTechnique: foodItem.cooking_technique, fat: foodItem.saturated_fat, glycemicIndex: parseGI(gi: foodItem.glycemic_index), dairy: foodItem.dairies == 1, gramPortion: foodItem.gram_per_portion)
            
            if let todayJournal = hasEntriesFromToday(entries: entries) {
                
                todayJournal.foods.append(food)
                
            } else {
                
                let journal = Journal(timestamp: Date(), foods: [], sleep: Sleep(timestamp: Date(), duration: 0))
                journal.foods.append(food)
                context.insert(journal)
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        } else {
            print("Food item not found")
        }
    }
    
    func parseFoodName(food: String) -> String {
        let formattedFood = food.replacingOccurrences(of: "_", with: " ")
        return formattedFood.prefix(1).capitalized + formattedFood.dropFirst()
    }
    
    private func hasEntriesFromToday(entries: [Journal]) -> Journal? {
        
        func isDateToday(_ date: Date) -> Bool {
            let calendar = Calendar.current
            return calendar.isDateInToday(date)
        }
        
        for entry in entries {
            if isDateToday(entry.timestamp) {
                return entry
            }
        }
        
        return nil
    }
    
    private func hasEntriesFromDate(entries: [Journal], date: Date) -> Journal? {
        let calendar = Calendar.current
        
        func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
            return calendar.isDate(date1, inSameDayAs: date2)
        }
        
        for entry in entries {
            if isSameDay(entry.timestamp, date) {
                return entry
            }
        }
        
        return nil
    }
    
    private func parseGI(gi: Int) -> glycemicIndex {
        switch gi {
        case 0:
            return .low
        case 1:
            return .medium
        case 2:
            return .high
        default:
            fatalError("Invalid glycemic index value")
        }
    }
    
    func sleepClassificationMessage(journals: [Journal]) -> String {
        let sleepDuration = getSleep(journals: journals)
        guard let hours = Int(sleepDuration.hour), let minutes = Int(sleepDuration.minute) else {
            return ""
        }
        
        let totalMinutes = (hours * 60) + minutes
        switch totalMinutes {
        case 0:
            return """
                        Tidak ada data
                       """
        case ..<480:
            return """
                        Kayaknya tidurmu kurang, nih! 
                        Banyakin istirahat, ya
                       """
        case 480...600:
            return """
                        Yay! Tidurmu tercukupi, nih!
                        Pertahankan, ya
                       """
        default:
            return """
                        Kayanya tidurmu kebanyakan, nih! 
                        Banyakin aktivitas ya
                       """
        }
    }
}


