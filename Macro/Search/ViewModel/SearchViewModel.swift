//
//  SearchViewModel.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 14/10/24.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class SearchViewModel: ObservableObject {
    
    let delay: TimeInterval = 0.3
    let defaults = UserDefaults.standard
    
    @Published var input: String = ""
    @Published var suggestions: [String] = []
    @Published var recent: [String] = []
    @Published var isPresented = false
    @Published var food: Food?
    @Published var selectedSuggestion: String?
    
    @Published var selectedProcessedOption = "Goreng"
    @Published var selectedFatOption = "Jenuh"
    @Published var selectedMilkOption = "Tidak Ada"
    @Published var selectedGlycemicOption = "Rendah"
    
    private let foodCache = FoodCache(source: FoodFile()!)

    private var task: Task<Void, Never>?
    
    init() {
        recent = defaults.array(forKey: "recent") as? [String] ?? []
    }

    func autocomplete(_ text: String) {
        guard !text.isEmpty else {
            suggestions = []
            task?.cancel()
            return
        }

        task?.cancel()

        task = Task {
            await Task.sleep(UInt64(delay * 1_000_000_000.0))

            guard !Task.isCancelled else {
                return
            }

            let newSuggestions = await foodCache.lookup(prefix: text)

            if isSingleSuggestion(suggestions, equalTo: text) {
                suggestions = []
            } else {
                suggestions = newSuggestions
            }
        }
    }

    private func isSingleSuggestion(_ suggestions: [String], equalTo text: String) -> Bool {
        guard let suggestion = suggestions.first, suggestions.count == 1 else {
            return false
        }

        return suggestion.lowercased() == text.lowercased()
    }
    
    func addFoodName(name: String, cookingTechnique: [String], glycemicIndex: Int, dairies: Int, saturatedFat: Double, gramPortion: Int) {
        print("Add Food Name")
        let fileManager = FileManager.default

        guard let filePath = Bundle.main.url(forResource: "Name", withExtension: nil) else {
            print("File 'Name' not found in bundle")
            return
        }

        let foodEntry = name + "\n"

        if fileManager.fileExists(atPath: filePath.path) {
            if let fileHandle = try? FileHandle(forWritingTo: filePath) {
                fileHandle.seekToEndOfFile()
                if let data = foodEntry.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            }
        } else {
            try? foodEntry.write(to: filePath, atomically: true, encoding: .utf8)
        }
        
        guard let url = Bundle.main.url(forResource: "FoodAndDrink", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              var foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON")
            return
        }
        
        let newFood = FoodItem(name: name, cooking_technique: cookingTechnique, glycemic_index: glycemicIndex, dairies: dairies, saturated_fat: saturatedFat, gram_per_portion: gramPortion)
        foodItems.append(newFood)
        
        guard let updatedData = try? JSONEncoder().encode(foodItems) else { return }
        try? updatedData.write(to: url)
    }

    
    func detailDiet(name: String) {
        
        guard let url = Bundle.main.url(forResource: "FoodAndDrink", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSONw")
            return
        }
        
        if let foodItem = foodItems.first(where: { $0.name == name }) {
            food = Food(timestamp: Date(), name: name, cookingTechnique: foodItem.cooking_technique, fat: foodItem.saturated_fat, glycemicIndex: parseGI(gi: foodItem.glycemic_index), dairy: foodItem.dairies == 1, gramPortion: foodItem.gram_per_portion)
            
            selectedProcessedOption = food?.cookingTechnique[0] ?? "Goreng"
            selectedFatOption = food?.fat ?? 0 >= 14 ? "Jenuh" : "Baik"
            selectedMilkOption = food?.dairy ?? false ? "Ada" : "Tidak Ada"
            switch food?.glycemicIndex {
            case .low:
                selectedGlycemicOption = "Rendah"
            case .medium:
                selectedGlycemicOption = "Sedang"
            case .high:
                selectedGlycemicOption = "Tinggi"
            case .none:
                selectedGlycemicOption = "Rendah"
            }
        }
        
    }
    
    func addDiet(context: ModelContext, name: String, entries: [Journal], portion: Int, unit: String) {
        
        manageRecently(name: name)
        
        guard let url = Bundle.main.url(forResource: "FoodAndDrink", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON")
            return
        }
                
        if let foodItem = foodItems.first(where: { $0.name == name }) {
            
            var gi: glycemicIndex
            switch selectedGlycemicOption {
            case "Rendah":
                gi = .low
            case "Sedang":
                gi = .medium
            case "Tinggi":
                gi = .high
            default:
                gi = .low
            }
            
            var mult: Int
            if unit == "Porsi" {
                mult = portion
            }
            else {
                mult = portion / foodItem.gram_per_portion
            }
            print("Mult: \(mult)")
            
            if let todayJournal = hasEntriesFromToday(entries: entries) {
                
                for _ in 0..<mult {
                    let food = Food(timestamp: Date(), name: name, cookingTechnique: [selectedProcessedOption], fat: foodItem.saturated_fat * (Double(foodItem.gram_per_portion) / 100), glycemicIndex: gi, dairy: selectedMilkOption == "Ada", gramPortion: foodItem.gram_per_portion)
                    todayJournal.foods.append(food)
                }
                
                print(todayJournal.foods)
                
            } else {
                let journal = Journal(timestamp: Date(), foods: [], sleep: Sleep(timestamp: Date(), duration: 0))
                
                for _ in 0..<mult {
                    let food = Food(timestamp: Date(), name: name, cookingTechnique: [selectedProcessedOption], fat: foodItem.saturated_fat * (Double(foodItem.gram_per_portion) / 100), glycemicIndex: gi, dairy: selectedMilkOption == "Ada", gramPortion: foodItem.gram_per_portion)
                    journal.foods.append(food)
                }
                                
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
    
    func clearRecent() {
        
        defaults.set([], forKey: "recent")
        recent = []
        
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
    
    private func parseGI(gi: Int) -> glycemicIndex {
        if gi <= 55 {
            return .low
        }
        else if gi <= 69 {
            return .medium
        }
        else {
            return .high
        }
    }
    
    private func manageRecently(name: String) {
        
        if var recent = defaults.array(forKey: "recent") as? [String] {
            if let index = recent.firstIndex(of: name) {
                recent.remove(at: index)
            }
            recent.append(name)
            defaults.set(recent, forKey: "recent")
            self.recent = recent
        }
        
    }
    
}

struct FoodItem: Codable {
    var name: String
    var cooking_technique: [String]
    var glycemic_index: Int
    var dairies: Int
    var saturated_fat: Double
    var gram_per_portion: Int
}
