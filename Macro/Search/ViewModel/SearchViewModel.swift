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

            suggestions = newSuggestions
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
        
        // Set up paths in Documents directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("Name")
        let jsonFilePath = documentsDirectory.appendingPathComponent("FoodAndDrink.json")
        
        // Ensure 'Name' file exists in Documents directory
        if !fileManager.fileExists(atPath: filePath.path) {
            if let bundleFilePath = Bundle.main.url(forResource: "Name", withExtension: nil) {
                try? fileManager.copyItem(at: bundleFilePath, to: filePath)
            } else {
                print("File 'Name' not found in bundle")
                return
            }
        }
        
        // Append the food name to the file in the Documents directory
        let foodEntry = name + "\n"
        if let fileHandle = try? FileHandle(forWritingTo: filePath) {
            fileHandle.seekToEndOfFile()
            if let data = foodEntry.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } else {
            try? foodEntry.write(to: filePath, atomically: true, encoding: .utf8)
        }
        
        // Ensure 'FoodAndDrink.json' exists in Documents directory
        if !fileManager.fileExists(atPath: jsonFilePath.path) {
            if let bundleJsonPath = Bundle.main.url(forResource: "FoodAndDrink", withExtension: "json") {
                try? fileManager.copyItem(at: bundleJsonPath, to: jsonFilePath)
            } else {
                print("Failed to find 'FoodAndDrink.json' in bundle")
                return
            }
        }
        
        // Load, modify, and save JSON data in Documents directory
        guard let data = try? Data(contentsOf: jsonFilePath),
              var foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON")
            return
        }
        
        // Add new food item and encode the updated list back to JSON
        let newFood = FoodItem(name: name, cooking_technique: cookingTechnique, glycemic_index: glycemicIndex, dairies: dairies, saturated_fat: saturatedFat, gram_per_portion: gramPortion)
        foodItems.append(newFood)
        
        guard let updatedData = try? JSONEncoder().encode(foodItems) else { return }
        try? updatedData.write(to: jsonFilePath)
    }

    func detailDiet(name: String) {
        // Updated to load JSON from Documents directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonFilePath = documentsDirectory.appendingPathComponent("FoodAndDrink.json")
        
        // Ensure 'FoodAndDrink.json' exists in Documents directory
        if !fileManager.fileExists(atPath: jsonFilePath.path) {
            if let bundleJsonPath = Bundle.main.url(forResource: "FoodAndDrink", withExtension: "json") {
                try? fileManager.copyItem(at: bundleJsonPath, to: jsonFilePath)
            } else {
                print("Failed to find 'FoodAndDrink.json' in bundle")
                return
            }
        }
        
        guard let data = try? Data(contentsOf: jsonFilePath),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON")
            return
        }
        
        if let foodItem = foodItems.first(where: { $0.name == name }) {
            food = Food(
                timestamp: Date(),
                name: name,
                cookingTechnique: foodItem.cooking_technique,
                fat: foodItem.saturated_fat,
                glycemicIndex: parseGI(gi: foodItem.glycemic_index),
                dairy: foodItem.dairies == 1,
                gramPortion: foodItem.gram_per_portion
            )
            
            // Update selected options for UI
            selectedProcessedOption = food?.cookingTechnique.first ?? "Goreng"
            selectedFatOption = (food?.fat ?? 0) * (Double(food?.gramPortion ?? 0) / 100) >= 5 ? "Jenuh" : "Baik"
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
    
    func addDiet(context: ModelContext, name: String, entries: [Journal], portion: Int, unit: String, date: Date) {
        
        manageRecently(name: name)
        
        // Load JSON from Documents directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonFilePath = documentsDirectory.appendingPathComponent("FoodAndDrink.json")
        
        guard let data = try? Data(contentsOf: jsonFilePath),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON!")
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
            
            let mult: Int = unit == "Porsi" ? portion : portion / foodItem.gram_per_portion
            print("Mult: \(mult)")
            
            var foodItemsToAdd: [Food] = []
            for _ in 0..<mult {
                let food = Food(
                    timestamp: date,
                    name: name,
                    cookingTechnique: [selectedProcessedOption],
                    fat: (selectedProcessedOption == "Goreng" || selectedFatOption == "Jenuh") ? 6 : (foodItem.saturated_fat * (Double(foodItem.gram_per_portion) / 100)),
                    glycemicIndex: gi,
                    dairy: selectedMilkOption == "Ada",
                    gramPortion: foodItem.gram_per_portion
                )
                foodItemsToAdd.append(food)
            }
            
            if let todayJournal = hasEntriesFromDate(entries: entries, date: date) {
                todayJournal.foods.append(contentsOf: foodItemsToAdd)
                print("Updated today’s journal with foods: \(todayJournal.foods)")
            } else {
                let journal = Journal(timestamp: date, foods: foodItemsToAdd, sleep: Sleep(timestamp: date, duration: 0, start: date, end: date))
                context.insert(journal)
                print("Created new journal with foods: \(journal.foods)")
            }
            
            do {
                try context.save()
                print("Data saved successfully.")
                print(date)
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
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
    
    func addDummyDiet(context: ModelContext) {
        
        let dietPlan: [(food: [(name: String, time: Int)], date: Date)] = [
            (
                food: [
                    (name: "Kue Cubit", time: 8),
                    (name: "Jus Strawberry", time: 8),
                    (name: "Nasi Goreng Seafood", time: 14),
                    (name: "Kerupuk Udang", time: 14),
                    (name: "Ayam Penyet dengan Sambal Bawang", time: 19)
                ],
                date: Date()
            ),
            (
                food: [
                    (name: "Donat Kentang", time: 8),
                    (name: "Kopi Susu Gula Aren", time: 8),
                    (name: "Pasta Carbonara", time: 14),
                    (name: "Salad Sayur", time: 14),
                    (name: "Bebek Goreng Sambal Ijo", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Bubur Ayam Cirebon", time: 8),
                    (name: "Kopi Susu Gula Aren", time: 8),
                    (name: "Nasi Padang (Rendang, Sayur Singkong)", time: 14),
                    (name: "Tahu Sumedang", time: 19),
                    (name: "Es Soda Gembira", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Nasi Goreng Kampung", time: 8),
                    (name: "Teh Susu", time: 8),
                    (name: "Ayam Geprek Mozarella", time: 14),
                    (name: "Sambal Matah", time: 14),
                    (name: "Mie Goreng Ayam", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Martabak Telur", time: 8),
                    (name: "Susu Kental Manis", time: 8),
                    (name: "Pizza Topping Ayam", time: 14),
                    (name: "Soto Betawi", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Lontong Sayur", time: 8),
                    (name: "Jus Mangga Susu", time: 8),
                    (name: "Ayam Bakar Taliwang", time: 14),
                    (name: "Sambal Pedas", time: 14),
                    (name: "Mie Rebus dengan Bakso", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Kue Cubit", time: 8),
                    (name: "Jus Strawberry", time: 8),
                    (name: "Nasi Goreng Seafood", time: 14),
                    (name: "Kerupuk Udang", time: 14),
                    (name: "Ayam Penyet dengan Sambal Bawang", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Pisang Goreng Keju", time: 8),
                    (name: "Kopi Hitam", time: 8),
                    (name: "Burger Ayam", time: 14),
                    (name: "Kentang Goreng", time: 14),
                    (name: "Ayam Goreng Kremes", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Indomie Goreng", time: 8),
                    (name: "Teh Tarik", time: 8),
                    (name: "Bakmi Ayam", time: 14),
                    (name: "Pangsit Goreng", time: 14),
                    (name: "Sate Ayam Madura", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Pisang Goreng Coklat", time: 8),
                    (name: "Teh Susu", time: 8),
                    (name: "Ayam Pop Padang", time: 14),
                    (name: "Nasi Kuning", time: 14),
                    (name: "Nasi Goreng Kambing", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -9, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Bubur Ayam Bandung", time: 8),
                    (name: "Infused Water Lemon", time: 8),
                    (name: "Soto Ayam", time: 14),
                    (name: "Nasi Putih", time: 14),
                    (name: "Ikan Bakar Sambal Matah", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -19, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Jus Semangka Kelapa", time: 8),
                    (name: "Bubur Sumsum", time: 8),
                    (name: "Tumis Kacang Panjang", time: 14),
                    (name: "Daging Panggang", time: 14),
                    (name: "Tumis Kangkung Saus Tiram", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Yogurt Buah Naga", time: 8),
                    (name: "Roti Tawar", time: 8),
                    (name: "Rawon", time: 14),
                    (name: "Nasi Merah", time: 14),
                    (name: "Sop Daging", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -17, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Smoothie Melon", time: 8),
                    (name: "Bubur Ayam Kuning", time: 8),
                    (name: "Ikan Gurame Asam Manis", time: 14),
                    (name: "Tumis Brokoli", time: 14),
                    (name: "Ayam Bakar Bumbu Rujak", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -16, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Susu Almond Coklat", time: 8),
                    (name: "Roti Gandum Panggang", time: 8),
                    (name: "Tahu Gejrot", time: 14),
                    (name: "Sop Buntut", time: 14),
                    (name: "Tumis Sawi", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Jus Nanas Mint", time: 8),
                    (name: "Nasi Kuning dengan Ayam Serundeng", time: 8),
                    (name: "Gulai Ayam", time: 14),
                    (name: "Tumis Bayam", time: 14),
                    (name: "Pecel Madiun", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Susu Jahe", time: 8),
                    (name: "Bubur Ayam Banjar", time: 8),
                    (name: "Nasi Lemak", time: 14),
                    (name: "Rendang Ayam", time: 14),
                    (name: "Tumis Labu Siam", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -13, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Jus Kiwi Lemon", time: 8),
                    (name: "Pancake Oatmeal", time: 8),
                    (name: "Soto Kudus", time: 14),
                    (name: "Nasi Putih", time: 14),
                    (name: "Sup Tomat Daging", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Smoothie Pisang", time: 8),
                    (name: "Bubur Sumsum Gula Merah", time: 8),
                    (name: "Cap Cay Kuah", time: 14),
                    (name: "Nasi Merah", time: 14),
                    (name: "Ikan Panggang Saus Padang", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -11, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Jus Apel Madu", time: 8),
                    (name: "Roti Pita dengan Selai Almond", time: 8),
                    (name: "Tumis Ayam Pedas", time: 14),
                    (name: "Tumis Kangkung", time: 14),
                    (name: "Sup Ayam Kampung", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Pisang Goreng Coklat", time: 8),
                    (name: "Teh Susu", time: 8),
                    (name: "Ayam Pop Padang", time: 14),
                    (name: "Nasi Kuning", time: 14),
                    (name: "Nasi Goreng Kambing", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -29, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Indomie Goreng", time: 8),
                    (name: "Teh Tarik", time: 8),
                    (name: "Bakmi Ayam", time: 14),
                    (name: "Pangsit Goreng", time: 14),
                    (name: "Sate Ayam Madura", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -28, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Pisang Goreng Keju", time: 8),
                    (name: "Kopi Hitam", time: 8),
                    (name: "Burger Ayam", time: 14),
                    (name: "Kentang Goreng", time: 14),
                    (name: "Ayam Goreng Kremes", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -27, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Kue Cubit", time: 8),
                    (name: "Jus Strawberry", time: 8),
                    (name: "Nasi Goreng Seafood", time: 14),
                    (name: "Kerupuk Udang", time: 14),
                    (name: "Ayam Penyet dengan Sambal Bawang", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -26, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Lontong Sayur", time: 8),
                    (name: "Jus Mangga Susu", time: 8),
                    (name: "Ayam Bakar Taliwang", time: 14),
                    (name: "Sambal Pedas", time: 14),
                    (name: "Mie Rebus dengan Bakso", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Martabak Telur", time: 8),
                    (name: "Susu Kental Manis", time: 8),
                    (name: "Pizza Topping Ayam", time: 14),
                    (name: "Soto Betawi", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -24, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Nasi Goreng Kampung", time: 8),
                    (name: "Teh Susu", time: 8),
                    (name: "Ayam Geprek Mozarella", time: 14),
                    (name: "Sambal Matah", time: 14),
                    (name: "Mie Goreng Ayam", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -23, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Bubur Ayam Cirebon", time: 8),
                    (name: "Kopi Susu Gula Aren", time: 8),
                    (name: "Nasi Padang (Rendang, Sayur Singkong)", time: 14),
                    (name: "Tahu Sumedang", time: 19),
                    (name: "Es Soda Gembira", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -22, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Donat Kentang", time: 8),
                    (name: "Kopi Susu Gula Aren", time: 8),
                    (name: "Pasta Carbonara", time: 14),
                    (name: "Salad Sayur", time: 14),
                    (name: "Bebek Goreng Sambal Ijo", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -21, to: Date()) ?? Date()
            ),
            (
                food: [
                    (name: "Kue Cubit", time: 8),
                    (name: "Jus Strawberry", time: 8),
                    (name: "Nasi Goreng Seafood", time: 14),
                    (name: "Kerupuk Udang", time: 14),
                    (name: "Ayam Penyet dengan Sambal Bawang", time: 19)
                ],
                date: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date()
            )

        ]
                
        // Load JSON from Documents directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonFilePath = documentsDirectory.appendingPathComponent("FoodAndDrink.json")
        
        // Ensure 'FoodAndDrink.json' exists in Documents directory
        if !fileManager.fileExists(atPath: jsonFilePath.path) {
            if let bundleJsonPath = Bundle.main.url(forResource: "FoodAndDrink", withExtension: "json") {
                try? fileManager.copyItem(at: bundleJsonPath, to: jsonFilePath)
            } else {
                print("Failed to find 'FoodAndDrink.json' in bundle")
                return
            }
        }
        
        guard let data = try? Data(contentsOf: jsonFilePath),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON!")
            return
        }
        
        for entry in dietPlan {
                    
            var foodItemsToAdd: [Food] = []
            for (name, time) in entry.food {
                
                if let foodItem = foodItems.first(where: { $0.name == name }) {
                    var gi = parseGI(gi: foodItem.glycemic_index)
                                        
                    let food = Food(
                        timestamp: Calendar.current.date(bySettingHour: time, minute: 0, second: 0, of: entry.date) ?? Date(),
                        name: name,
                        cookingTechnique: foodItem.cooking_technique,
                        fat: foodItem.saturated_fat,
                        glycemicIndex: gi,
                        dairy: foodItem.dairies == 1,
                        gramPortion: foodItem.gram_per_portion
                    )
                    foodItemsToAdd.append(food)
                }
            }
            
            let journal = Journal(timestamp: entry.date, foods: foodItemsToAdd, sleep: Sleep(timestamp: entry.date, duration: 0, start: entry.date, end: entry.date))
            context.insert(journal)
            
            do {
                try context.save()
                print("Data saved successfully.")
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
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
