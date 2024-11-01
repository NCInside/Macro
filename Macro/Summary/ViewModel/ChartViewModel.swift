//
//  ChartViewModel.swift
//  Macro
//
//  Created by Vebrillia Santoso on 17/10/24.
//

import Foundation

class ChartCardViewModel: ObservableObject {
    @Published var selectedTab = "Mingguan"
    
    var tabs = ["Mingguan", "Bulanan"]

    var weeklyData = [SavedData(dateLabel: "Sen", value: 100),
                      SavedData(dateLabel: "Sel", value: 200),
                      SavedData(dateLabel: "Rab", value: 300),
                      SavedData(dateLabel: "Kam", value: 400),
                      SavedData(dateLabel: "Jum", value: 500),
                      SavedData(dateLabel: "Sab", value: 600),
                      SavedData(dateLabel: "Min", value: 700)]
    
    var monthlyData = [SavedData(dateLabel: "1 Oct", value: 100),
                       SavedData(dateLabel: "2 Oct", value: 200),
                       SavedData(dateLabel: "3 Oct", value: 300),
                       SavedData(dateLabel: "4 Oct", value: 400),
                       SavedData(dateLabel: "5 Oct", value: 500)]
    
    var chartData: [SavedData] {
        switch selectedTab {
        case "Mingguan":
            return weeklyData
        case "Bulanan":
            return monthlyData
        default:
            return []
        }
    }
}

struct SavedData: Identifiable {
    var id = UUID()
    let dateLabel: String
    let value: Double
}
