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
    @Published var freqMilk: Int = 0
    @Published var ind: String = ""
    @Published var points: [Point] = []
    @Published var piePoints: [PiePoint] = []
    @Published var selectedTab = "Mingguan"
        
    func updateValue(journals: [Journal], chosenMonth: Int) {
        
        let filteredJournals = journals.filter { Calendar.current.component(.month, from: $0.timestamp) == chosenMonth }
        let n = filteredJournals.count
        guard n > 0 else { 
            avgSleep = 0
            avgFat = 0
            freqMilk = 0
            ind = ""

            return
        }
        avgSleep = ( filteredJournals.reduce(0) { $0 + Int($1.sleep.duration) } ) / n
        avgFat = ( filteredJournals.flatMap { $0.foods }.reduce(0) { $0 + Int($1.fat) } ) / n
        freqMilk = (filteredJournals.flatMap { $0.foods }.reduce(0) { $0 + ($1.dairy ? 1 : 0) }) / n
        let glycemicIndexCounts = filteredJournals
                    .flatMap { $0.foods }
                    .reduce(into: [glycemicIndex: Int]()) { counts, food in
                        counts[food.glycemicIndex, default: 0] += 1
                    }
        if let mostFrequentIndex = glycemicIndexCounts.max(by: { $0.value < $1.value })?.key {
            ind = "\(mostFrequentIndex)"
        } else {
            ind = "Unknown"
        }
        
    }
    
    func getPoints(journals: [Journal], scenario: scenario, chosenMonth: Int) {
        
        let filteredJournals = journals.filter { Calendar.current.component(.month, from: $0.timestamp) == chosenMonth }
        points = []
        
        switch scenario {
        case .sleep:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: journal.sleep.duration / 3600)
                points.append(point)
            }
        case .protein:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: Int(journal.foods.reduce(0) { $0 + $1.protein }))
                points.append(point)
            }
        case .fat:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: Int(journal.foods.reduce(0) { $0 + $1.fat }))
                points.append(point)
            }
        case .dairy:
            for journal in filteredJournals {
                let point = Point(date: journal.timestamp, value: Int(journal.foods.reduce(0) { $0 + ($1.dairy ? 1 : 0) }))
                points.append(point)
            }
        case .gi:
            for journal in filteredJournals {
//                var point: Point
                let glycemicIndexCounts = journal.foods.reduce(into: [glycemicIndex: Int]()) { counts, food in
                    counts[food.glycemicIndex, default: 0] += 1
                }
                
                piePoints = glycemicIndexCounts.map { (key, value) in
                    let category: String
                    switch key {
                    case .low: category = "Low"
                    case .medium: category = "Medium"
                    case .high: category = "High"
                    }
                    return PiePoint(date: journal.timestamp, category: category, value:value)
                }
                
//                let majorityGlycemicIndex = glycemicIndexCounts.max(by: { $0.value < $1.value })?.key
//                
//                switch majorityGlycemicIndex {
//                case .low:
//                    point = Point(date: journal.timestamp, value: 1)
//                case .medium:
//                    point = Point(date: journal.timestamp, value: 2)
//                case .high:
//                    point = Point(date: journal.timestamp, value: 3)
//                case .none:
//                    point = Point(date: journal.timestamp, value: 0)
//                }
//                points.append(point)
            }
        }
        
        self.points = points
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

    
}

enum scenario {
    case sleep, fat, dairy, gi
}

struct Point: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

struct PiePoint {
    let date: Date
    let category: String
    let value: Int
}
