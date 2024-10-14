//
//  JournalViewModel.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import Foundation
import UIKit

class JournalViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedImage: UIImage?
    @Published var isImagePickerPresented: Bool = false
    @Published var isDietViewPresented: Bool = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var sleepDuration: String = "0hr 0min"
    private var healthManager = HealthManager()
    
    var days: [String] {
        return ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"]
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
    
    func fetchSleepData() {
            healthManager.fetchSleepData { [weak self] sample in
                DispatchQueue.main.async {
                    guard let sample = sample else {
                        self?.sleepDuration = "No data"
                        return
                    }
                    
                    let sleepTime = sample.endDate.timeIntervalSince(sample.startDate)
                    let hours = Int(sleepTime) / 3600
                    let minutes = (Int(sleepTime) % 3600) / 60
                    
                    self?.sleepDuration = "\(hours)hr \(minutes)min"
                }
            }
        }
}


