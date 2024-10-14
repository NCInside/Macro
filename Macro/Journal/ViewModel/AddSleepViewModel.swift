//
//  AddSleepViewModel.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI

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
        
        var components = DateComponents()
        components.hour = hour
        components.minute = Int(minute)
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func getTimeDifference() -> (Int, Int) {
        let calendar = Calendar.current
        
        var startTime = getTime(angle: startAngle)
        var endTime = getTime(angle: toAngle)
        
        if endTime < startTime {
            endTime = calendar.date(byAdding: .day, value: 1, to: endTime) ?? endTime
        }
        
        let result = calendar.dateComponents([.hour, .minute], from: startTime, to: endTime)
        
        return (result.hour ?? 0, result.minute ?? 0)
    }

}

