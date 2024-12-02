import SwiftUI
import SwiftData
import UIKit

@MainActor
class JournalImageViewModel: ObservableObject {
    @Published var journalImages: [JournalImage] = []
    @Published var breakoutAnalysis: [(foodName: String, totalGram: Int, percentageDuringBreakouts: Double)] = []
    
    @Published var peakConsumption: PeakConsumption?
    private let context: ModelContext
    private var lastBreakoutDate: Date?
    
    init(context: ModelContext) {
        self.context = context
        fetchJournalImages()
        fetchPeakConsumption()
    }
    func fetchPeakConsumption() {
           let fetchRequest = FetchDescriptor<PeakConsumption>()
           do {
               if let peak = try context.fetch(fetchRequest).first {
                   self.peakConsumption = peak
               } else {
                   // If no PeakConsumption exists, create a default one
                   let newPeak = PeakConsumption()
                   context.insert(newPeak)
                   try context.save()
                   self.peakConsumption = newPeak
               }
           } catch {
               print("Failed to fetch PeakConsumption: \(error.localizedDescription)")
           }
       }
    func topFoodsBasedOnPeakConsumption() -> [(foodName: String, glycemicIndex: Int, fat: Double, dairies: Int)] {
        guard let peak = peakConsumption else { return [] }
        let calendar = Calendar.current
        let today = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return [] }
        
        var foodData: [String: (glycemicIndex: Int, fat: Double, dairies: Int)] = [:]
        
        let journalsForPeriod = journalImages.filter { $0.timestamp >= sevenDaysAgo && $0.isBreakout }
        
        for journal in journalsForPeriod {
            let foods = fetchFoodsForJournal(at: journal.timestamp)
            for food in foods {
                if food.glycemicIndex.rawValue >= peak.highestGlycemicIndex ||
                    food.fat >= peak.highestFat ||
                    (food.dairy ? 1 : 0) >= peak.highestDairy {
                    
                    if let existingData = foodData[food.name] {
                        foodData[food.name] = (
                            glycemicIndex: max(existingData.glycemicIndex, food.glycemicIndex.rawValue),
                            fat: existingData.fat + food.fat,
                            dairies: existingData.dairies + (food.dairy ? 1 : 0)
                        )
                    } else {
                        foodData[food.name] = (
                            glycemicIndex: food.glycemicIndex.rawValue,
                            fat: food.fat,
                            dairies: food.dairy ? 1 : 0
                        )
                    }
                }
            }
        }
        
        return foodData
            .sorted {
                ($0.value.glycemicIndex + Int($0.value.fat) + $0.value.dairies) >
                ($1.value.glycemicIndex + Int($1.value.fat) + $1.value.dairies)
            }
            .prefix(3)
            .map { (foodName: $0.key, glycemicIndex: $0.value.glycemicIndex, fat: $0.value.fat, dairies: $0.value.dairies) }
    }
    
    func frequentFoodsForBreakouts(minimumFrequency: Double = 50.0) -> [(foodName: String, frequency: Double)] {
        let totalBreakoutDays = journalImages.filter { $0.isBreakout }.count
        guard totalBreakoutDays > 0 else { return [] }
        
        var foodCounts: [String: Int] = [:]
        let breakoutJournals = journalImages.filter { $0.isBreakout }
        
        for journal in breakoutJournals {
            let foods = fetchFoodsForJournal(at: journal.timestamp)
            for food in foods {
                foodCounts[food.name, default: 0] += 1
            }
        }
        
        return foodCounts
            .map { (foodName: $0.key, frequency: (Double($0.value) / Double(totalBreakoutDays)) * 100) }
            .filter { $0.frequency >= minimumFrequency }
            .sorted { $0.frequency > $1.frequency }
    }
    
    func fetchDataForLast7Days() -> [(date: Date, glycemicIndex: Int, fat: Double, dairies: Int)] {
        let calendar = Calendar.current
        let today = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return [] }
        
        var dataForLast7Days: [(date: Date, glycemicIndex: Int, fat: Double, dairies: Int)] = []
        
        // Filter journal images for the last 7 days
        let journalsForPeriod = journalImages.filter { $0.timestamp >= sevenDaysAgo && $0.timestamp <= today }
        
        // Loop through each journal and calculate totals
        for journal in journalsForPeriod {
            let foods = fetchFoodsForJournal(at: journal.timestamp)
            var totalGlycemicIndex = 0
            var totalFat = 0.0
            var totalDairies = 0
            
            for food in foods {
                totalGlycemicIndex += food.glycemicIndex.rawValue
                totalFat += food.fat
                totalDairies += food.dairy ? 1 : 0
            }
            
            dataForLast7Days.append((date: journal.timestamp, glycemicIndex: totalGlycemicIndex, fat: totalFat, dairies: totalDairies))
        }
        
        return dataForLast7Days.sorted(by: { $0.date > $1.date })
    }
    func addDummyDataForLast30Days() {
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // Add dummy data for each day
                addJournalImage(
                    timestamp: date,
                    image: nil, // No image for dummy data
                    isBreakout: false, // Breakout is false for dummy data
                    isMenstrual: false, // You can adjust this if needed
                    notes: "Dummy entry for \(dateFormatter.string(from: date))"
                )
            }
        }
        
        // Refresh the view after adding the data
        fetchJournalImages()
    }
    
    func analyzeBreakoutCausingFoods() -> [(foodName: String, totalGram: Int, percentageDuringBreakouts: Double)] {
        let calendar = Calendar.current
        var foodFrequency: [String: (totalGram: Int, duringBreakouts: Int, totalConsumption: Int)] = [:]

        // Cari breakout terbaru
        guard let latestBreakout = journalImages.filter({ $0.isBreakout }).sorted(by: { $0.timestamp > $1.timestamp }).first else {
            return []
        }

        // Hitung 7 hari terakhir untuk breakout terbaru
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: latestBreakout.timestamp) else {
            return []
        }

        // Filter jurnal untuk 7 hari terakhir breakout terbaru
        let journalsForPeriod = journalImages.filter { $0.timestamp >= sevenDaysAgo && $0.timestamp <= latestBreakout.timestamp }

        // Loop untuk seluruh jurnal untuk data historis
        for journal in journalImages {
            let foods = fetchFoodsForJournal(at: journal.timestamp)
            for food in foods {
                let isDuringBreakout = journal.isBreakout
                let foodData = foodFrequency[food.name] ?? (totalGram: 0, duringBreakouts: 0, totalConsumption: 0)

                foodFrequency[food.name] = (
                    totalGram: foodData.totalGram + food.gramPortion,
                    duringBreakouts: foodData.duringBreakouts + (isDuringBreakout ? 1 : 0),
                    totalConsumption: foodData.totalConsumption + 1
                )
            }
        }

        // Ambil makanan dari periode breakout terbaru
        let relevantFoods = Set(journalsForPeriod.flatMap { fetchFoodsForJournal(at: $0.timestamp).map { $0.name } })

        // Filter makanan yang muncul dalam breakout terbaru
        return foodFrequency
            .filter { relevantFoods.contains($0.key) }
            .compactMap { foodName, data in
                guard data.totalConsumption > 0 else { return nil }
                let percentage = (Double(data.duringBreakouts) / Double(data.totalConsumption)) * 100
                return (foodName: foodName, totalGram: data.totalGram, percentageDuringBreakouts: percentage)
            }
            .sorted { $0.percentageDuringBreakouts > $1.percentageDuringBreakouts } // Urutkan berdasarkan persentase
    }
    
    func fetchFoodsByDayForLast7DaysFromBreakout() -> [(date: Date, foodNames: [String])] {
        let calendar = Calendar.current
        
        // Cari breakout terbaru
        guard let latestBreakout = journalImages.filter({ $0.isBreakout }).sorted(by: { $0.timestamp > $1.timestamp }).first else {
            return [] // Tidak ada breakout, kembalikan array kosong
        }

        // Hitung 7 hari sebelum breakout terbaru
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: latestBreakout.timestamp) else {
            return []
        }
        
        // Filter jurnal untuk 7 hari terakhir dari breakout terbaru
        let journalsForPeriod = journalImages.filter { $0.timestamp >= sevenDaysAgo && $0.timestamp <= latestBreakout.timestamp }
            .sorted(by: { $0.timestamp > $1.timestamp }) // Urutkan dari tanggal terbaru ke terlama

        var foodByDay: [(date: Date, foodNames: [String])] = []

        // Ambil data makanan dari jurnal selama periode tersebut
        for journal in journalsForPeriod {
            let foods = fetchFoodsForJournal(at: journal.timestamp)
            let foodNames = foods.map { $0.name } // Ambil nama makanan/minuman
            if !foodNames.isEmpty {
                foodByDay.append((date: journal.timestamp, foodNames: foodNames))
            }
        }

        return foodByDay
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    // Fetch all JournalImage entries
    func fetchJournalImages(for date: Date? = nil) {
        let descriptor = FetchDescriptor<JournalImage>()
        do {
            let fetchedImages = try context.fetch(descriptor)
            if let date = date {
                let calendar = Calendar.current
                journalImages = fetchedImages.filter {
                    calendar.isDate($0.timestamp, inSameDayAs: date)
                }
            } else {
                journalImages = fetchedImages
            }
        } catch {
            print("Failed to fetch JournalImages: \(error.localizedDescription)")
        }
    }
    
    // Add or update a JournalImage entry
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
            
            // Handle breakout logic
            if isBreakout {
                if isMenstrual {
                    print("PMS is the cause; skipping food tracking.")
                } else {
                    handleBreakout(for: timestamp)
                }
            } else {
                removeFoodsForBreakout(at: timestamp)
            }
        } catch {
            print("Failed to save JournalImage: \(error.localizedDescription)")
        }
    }
    
    private func handleBreakout(for breakoutDate: Date) {
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: breakoutDate) else { return }
        
        // Check cooldown period
        guard let cooldownEndDate = lastBreakoutDate.flatMap({ calendar.date(byAdding: .day, value: 3, to: $0) }) else {
            lastBreakoutDate = breakoutDate
            return saveFoodsForBreakout(from: sevenDaysAgo, to: breakoutDate)
        }
        
        if breakoutDate >= cooldownEndDate {
            saveFoodsForBreakout(from: sevenDaysAgo, to: breakoutDate)
            lastBreakoutDate = breakoutDate
        }
    }
    
    private func saveFoodsForBreakout(from startDate: Date, to endDate: Date) {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<JournalImage>()
        let journals: [JournalImage]
        do {
            journals = try context.fetch(descriptor).filter {
                $0.timestamp >= startDate && $0.timestamp <= endDate
            }
        } catch {
            print("Failed to fetch journals for breakout: \(error.localizedDescription)")
            return
        }
        
        var existingFoodNames: Set<String> = Set(fetchFoodsForBreakouts(from: startDate, to: endDate).map { $0.foodName })
        
        for journal in journals {
            for food in fetchFoodsForJournal(at: journal.timestamp) {
                if !existingFoodNames.contains(food.name) {
                    saveFoodBreakout(food: food, breakoutDate: endDate)
                    existingFoodNames.insert(food.name)
                }
            }
        }
    }
    
    private func removeFoodsForBreakout(at breakoutDate: Date) {
        let descriptor = FetchDescriptor<FoodBreakout>()
        do {
            let breakouts = try context.fetch(descriptor).filter { $0.breakoutDate == breakoutDate }
            for breakout in breakouts {
                context.delete(breakout)
            }
            try context.save()
        } catch {
            print("Failed to delete foods for breakout: \(error.localizedDescription)")
        }
    }
    
    private func fetchFoodsForBreakouts(from startDate: Date, to endDate: Date) -> [FoodBreakout] {
        let descriptor = FetchDescriptor<FoodBreakout>()
        do {
            return try context.fetch(descriptor).filter { $0.breakoutDate >= startDate && $0.breakoutDate <= endDate }
        } catch {
            print("Failed to fetch foods for breakouts: \(error.localizedDescription)")
            return []
        }
    }
    
    private func fetchFoodsForJournal(at date: Date) -> [Food] {
        let descriptor = FetchDescriptor<Food>()
        let calendar = Calendar.current
        do {
            return try context.fetch(descriptor).filter {
                calendar.isDate($0.timestamp, inSameDayAs: date)
            }
        } catch {
            print("Failed to fetch foods for journal: \(error.localizedDescription)")
            return []
        }
    }
    
    private func saveFoodBreakout(food: Food, breakoutDate: Date) {
        let newFoodBreakout = FoodBreakout(
            foodName: food.name,
            gramPortion: food.gramPortion,
            breakoutDate: breakoutDate
        )
        context.insert(newFoodBreakout)
        do {
            try context.save()
        } catch {
            print("Failed to save FoodBreakout: \(error.localizedDescription)")
        }
    }
    // Update an existing JournalImage entry
    func updateJournalImage(journalImage: JournalImage, newImage: UIImage? = nil, isBreakout: Bool? = nil, isMenstrual: Bool? = nil, notes: String? = nil) {
        // Update fields if new values are provided
        if let newImage = newImage, let imageData = newImage.jpegData(compressionQuality: 1.0) {
            journalImage.image = imageData
        }
        
        var breakoutStatusChanged = false
        if let isBreakout = isBreakout, journalImage.isBreakout != isBreakout {
            journalImage.isBreakout = isBreakout
            breakoutStatusChanged = true
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
            
            // Handle breakout logic
            if breakoutStatusChanged {
                if journalImage.isBreakout {
                    if journalImage.isMenstrual {
                        print("PMS is the cause; skipping food tracking.")
                    } else {
                        handleBreakout(for: journalImage.timestamp)
                    }
                } else {
                    removeFoodsForBreakout(at: journalImage.timestamp)
                }
            }
        } catch {
            print("Failed to update JournalImage: \(error.localizedDescription)")
        }
    }
    // Delete a JournalImage entry
    func deleteJournalImage(journalImage: JournalImage) {
        let breakoutDate = journalImage.timestamp
        let wasBreakout = journalImage.isBreakout
        
        // Remove the journal image
        context.delete(journalImage)
        
        do {
            try context.save()
            
            // Remove associated food breakout records if this journal was a breakout
            if wasBreakout {
                removeFoodsForBreakout(at: breakoutDate)
            }
            
            // Update the local list of journal images
            if let index = journalImages.firstIndex(of: journalImage) {
                journalImages.remove(at: index)
            }
        } catch {
            print("Failed to delete JournalImage: \(error.localizedDescription)")
        }
    }
}
