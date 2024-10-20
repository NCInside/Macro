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
            
            var first: Date = Date()
            var last: Date = Date()
            
            healthManager.fetchSleepData { samples in
                DispatchQueue.main.async {
                    guard let samples = samples, !samples.isEmpty else {
                        return
                    }
                    
                    first = samples.first?.endDate ?? Date()
                    last = samples.last?.startDate ?? Date()
                }
            }
            
            let sleep: Sleep = Sleep(timestamp: Date(), duration: Int(first.timeIntervalSince(last)), start: first, end: last)
            let journal = Journal(timestamp: Date(), foods: [], sleep: sleep)
            
            context.insert(journal)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func getSleep(journals: [Journal]) -> String {
        
        if let journal = hasEntriesFromDate(entries: journals, date: selectedDate) {
            let sleep = journal.sleep
            
            if sleep.duration == 0 {
                return "No Data"
            }
            
            let hour: Int = sleep.duration / 3600
            let minut: Int = (sleep.duration % 3600) / 60
            
            return "\(hour)hrs \(minut)min"
        }
        
        return "No Data"
    }
    
    func calcProtein(journals: [Journal]) -> Double {
        var protein: Double = 0
        if let todayJournal = hasEntriesFromDate(entries: journals, date: selectedDate) {
            for food in todayJournal.foods {
                protein += food.protein
            }
        }
        return protein
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
                
        if let foodItem = foodItems.first(where: { $0.NamaMakanan == name }) {
            
            let food = Food(timestamp: Date(), name: name, protein: foodItem.Protein, fat: foodItem.Fat, glycemicIndex: parseGI(gi: foodItem.GI), dairy: foodItem.Dairy == 1)
            
            if let todayJournal = hasEntriesFromToday(entries: entries) {
                
                todayJournal.foods.append(food)
                
            } else {
                
                let journal = Journal(timestamp: Date(), foods: [], sleep: Sleep(timestamp: Date(), duration: 0, start: Date(), end: Date()))
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

}


