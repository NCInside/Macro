//
//  AddSleepViewModel.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI
import SwiftData

class AddSleepViewModel: ObservableObject {
    @Published var startAngle: Double = 330
    @Published var toAngle: Double = 90
    
    @Published var startProgress: CGFloat = 330 / 360
    @Published var toProgress: CGFloat = 90 / 360
    
    func onDrag(value: DragGesture.Value, fromSlider: Bool = false) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy - 15, vector.dx - 15)
        
        var angle = radians * 180 / .pi
        if angle < 0 { angle = 360 + angle }
        
        let progress = angle / 360
        
        if fromSlider {
            self.startAngle = angle
            self.startProgress = progress
        } else {
            self.toAngle = angle
            self.toProgress = progress
        }
    }
    
    func getTime(angle: Double) -> Date {
        let progress = angle / 15
        
        let hour = Int(progress)
        let remainder = (progress.truncatingRemainder(dividingBy: 1) * 60).rounded()
        
        let minute = (Int(remainder) / 5) * 5
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        if hour >= 12 {
            components.day = components.day! - 1
        }
        
        components.hour = hour
        components.minute = Int(minute)
        
        return Calendar.current.date(from: components) ?? Date()
    }

    
    func getTimeDifference() -> (Int, Int) {
        let calendar = Calendar.current
        
        let startTime = getTime(angle: startAngle)
        var endTime = getTime(angle: toAngle)
        
        if endTime < startTime {
            endTime = calendar.date(byAdding: .day, value: 1, to: endTime) ?? endTime
        }
        
        let result = calendar.dateComponents([.hour, .minute], from: startTime, to: endTime)
        
        return (result.hour ?? 0, result.minute ?? 0)
    }
    
    func addSleep(context: ModelContext, journals: [Journal]) {
        let startTime: Date = Calendar.current.date(byAdding: .hour, value: 7, to: getTime(angle: startAngle)) ?? Date()
        let endTime: Date = Calendar.current.date(byAdding: .hour, value: 7, to: getTime(angle: toAngle)) ?? Date()
        
        if let journal = hasEntriesFromToday(entries: journals) {
            journal.sleep = Sleep(timestamp: Date(), duration: Int(endTime.timeIntervalSince(startTime)), start: startTime, end: endTime)
        }
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

}

