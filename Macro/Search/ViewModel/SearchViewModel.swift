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
    
    func detailDiet(name: String) {
        
        guard let url = Bundle.main.url(forResource: "NutrisiMakanan", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foodItems = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("Failed to load or decode JSON")
            return
        }
        
        if let foodItem = foodItems.first(where: { $0.NamaMakanan == name }) {
            food = Food(timestamp: Date(), name: name, protein: foodItem.Protein, fat: foodItem.Fat, glycemicIndex: parseGI(gi: foodItem.GI), dairy: foodItem.Dairy == 1)
        }
        
    }
    
    func addDiet(context: ModelContext, name: String, entries: [Journal]) {
        
        manageRecently(name: name)
        
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
    let NamaMakanan: String
    let GI: Int
    let Dairy: Int
    let Protein: Double
    let Fat: Double
    
    private enum CodingKeys : String, CodingKey {
        case NamaMakanan = "Nama Makanan"
        case GI
        case Dairy
        case Protein
        case Fat
    }
}
