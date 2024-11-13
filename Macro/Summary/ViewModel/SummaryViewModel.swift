//
//  SummaryViewModel.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 17/10/24.
//

import Foundation
import SwiftData
import Combine

@MainActor
class SummaryViewModel: ObservableObject {
    
    @Published var avgSleep: Int = 0
    @Published var avgFat: Int = 0
    @Published var avgSaturatedFat: Double = 0
    @Published var freqMilk: Int = 0
    @Published var ind: String = ""
    @Published var piePoints: [PiePoint] = []
    @Published var selectedTab = "Mingguan"
    @Published var dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "dd MMM yyyy"
    }
        
    func updateValue(journals: [Journal], chosenMonth: Int) {
        
        let filteredJournals = journals.filter { Calendar.current.component(.month, from: $0.timestamp) == chosenMonth }
        let n = filteredJournals.count
        guard n > 0 else { 
            avgSleep = 0
            avgFat = 0
            avgSaturatedFat = 0
            freqMilk = 0
            ind = ""

            return
        }
        avgSleep = ( filteredJournals.reduce(0) { $0 + Int($1.sleep.duration) } ) / n
        avgFat = filteredJournals.flatMap { $0.foods }.filter { $0.fat >= 5 }.count / n
        avgSaturatedFat = ( filteredJournals.flatMap { $0.foods }.reduce(0) { $0 + $1.fat } ) / Double(n)
        freqMilk = (filteredJournals.flatMap { $0.foods }.reduce(0) { $0 + ($1.dairy ? 1 : 0) }) / n
        let glycemicIndexCounts = filteredJournals
                    .flatMap { $0.foods }
                    .reduce(into: [glycemicIndex: Int]()) { counts, food in
                        counts[food.glycemicIndex, default: 0] += 1
                    }
        if let mostFrequentIndex = glycemicIndexCounts.max(by: { $0.value < $1.value })?.key {
            switch mostFrequentIndex {
            case .high:
                ind = "Tinggi"
            case .medium:
                ind = "Sedang"
            case .low:
                ind = "Rendah"
            }
        } else {
            ind = "Unknown"
        }
        
    }
    
    func getPoints(journals: [Journal], scenario: scenario, chosenMonth: Int) -> [Point] {
        
        let filteredJournals = journals.filter { Calendar.current.component(.month, from: $0.timestamp) == chosenMonth }
        var points: [Point] = []
        
        switch scenario {
        case .sleep:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: journal.sleep.duration / 3600)
                points.append(point)
            }
        case .fat:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: journal.foods.filter { $0.fat >= 5 }.count)
                points.append(point)
            }
        case .dairy:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: Int(journal.foods.reduce(0) { $0 + ($1.dairy ? 1 : 0) }))
                points.append(point)
            }
        case .gi:
            piePoints = []
            for journal in filteredJournals {
                let glycemicIndexCounts = journal.foods.reduce(into: [glycemicIndex: Int]()) { counts, food in
                    counts[food.glycemicIndex, default: 0] += 1
                }
                
                for (key, value) in glycemicIndexCounts {
                    let category: String
                    switch key {
                    case .low:
                        category = "Low"
                    case .medium:
                        category = "Medium"
                    case .high:
                        category = "High"
                    }
                    
                    let piePoint = PiePoint(date: journal.timestamp, category: category, value: value)
                    piePoints.append(piePoint)
                }
            }
        }
        
        return points
    }
    
    func getGIPoints(journals: [Journal], chosenMonth: Int) -> [PiePoint] {
        
        let filteredJournals = journals.filter { Calendar.current.component(.month, from: $0.timestamp) == chosenMonth }
        var points: [PiePoint] = []
        
        for journal in filteredJournals {
            let glycemicIndexCounts = journal.foods.reduce(into: [glycemicIndex: Int]()) { counts, food in
                counts[food.glycemicIndex, default: 0] += 1
            }
            
            for (key, value) in glycemicIndexCounts {
                let category: String
                switch key {
                case .low:
                    category = "Low"
                case .medium:
                    category = "Medium"
                case .high:
                    category = "High"
                }
                
                let piePoint = PiePoint(date: journal.timestamp, category: category, value: value)
                points.append(piePoint)
            }
        }
        
        return points
    }
    
    func getWeeks(of points: [Point]) -> [Int: [Point]] {
        var weeks: [Int: [Point]] = [:]
        let calendar = Calendar.current
        
        for point in points {
            let weekOfMonth = calendar.component(.weekOfMonth, from: point.date)
            if weeks[weekOfMonth] != nil {
                weeks[weekOfMonth]?.append(point)
            }
            else {
                weeks[weekOfMonth] = [point]
            }
        }
        return weeks
    }
    
    func getWeeksPie(of points: [PiePoint]) -> [Int: [PiePoint]] {
        var weeks: [Int: [PiePoint]] = [:]
        let calendar = Calendar.current
        
        for point in points {
            let weekOfMonth = calendar.component(.weekOfMonth, from: point.date)
            if weeks[weekOfMonth] != nil {
                weeks[weekOfMonth]?.append(point)
            }
            else {
                weeks[weekOfMonth] = [point]
            }
        }
        return weeks
    }
    
    func calcEnergyExpenditure() -> Double {
        let age = UserDefaults.standard.integer(forKey: "age")
        let height = UserDefaults.standard.double(forKey: "height")
        let heightMetric = UserDefaults.standard.string(forKey: "heightMetric")
        let weight = UserDefaults.standard.double(forKey: "weight")
        let weightMetric = UserDefaults.standard.string(forKey: "weightMetric")
        let gender = UserDefaults.standard.bool(forKey: "gender")
        let activityLevel = UserDefaults.standard.double(forKey: "activity")
        
        let heightInInches: Double
        if heightMetric == "ft" {
            heightInInches = height * 12.0
        } else {
            heightInInches = height * 0.393701
        }

        let weightInPounds: Double
        if weightMetric == "kg" {
            weightInPounds = weight * 2.20462
        } else {
            weightInPounds = weight
        }

        let bmr: Double
        if gender {
            bmr = 66 + (6.23 * weightInPounds) + (12.7 * heightInInches) - (6.8 * Double(age))
        } else {
            bmr = 655 + (4.35 * weightInPounds) + (4.7 * heightInInches) - (4.7 * Double(age))
        }

        return bmr * activityLevel
    }
    
    func hasBreakoutImage(on date: Date, in journalImages: [JournalImage]) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
                
        return journalImages.contains { image in
            let imageDate = calendar.startOfDay(for: image.timestamp)
            return imageDate == targetDate && image.isBreakout
        }
    }
    
    func aggregatedPiePoints() -> [PiePoint] {
        var aggregatedPoints: [String: Int] = [:]
        
        for point in piePoints {
            if let existingValue = aggregatedPoints[point.category] {
                aggregatedPoints[point.category] = existingValue + point.value
            } else {
                aggregatedPoints[point.category] = point.value
            }
        }
        
        return aggregatedPoints.map { PiePoint(date: Date(), category: $0.key, value: $0.value) }
    }

    
}

enum scenario {
    case sleep, fat, dairy, gi
}

struct Point: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

struct PiePoint: Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let value: Int
}
