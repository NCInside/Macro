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

    var weeklyData = [SavingsData(dateLabel: "Sen", value: 100),
                      SavingsData(dateLabel: "Sel", value: 200),
                      SavingsData(dateLabel: "Rab", value: 300),
                      SavingsData(dateLabel: "Kam", value: 400),
                      SavingsData(dateLabel: "Jum", value: 500),
                      SavingsData(dateLabel: "Sab", value: 600),
                      SavingsData(dateLabel: "Min", value: 700)]
    
    var monthlyData = [SavingsData(dateLabel: "1 Oct", value: 100),
                       SavingsData(dateLabel: "2 Oct", value: 200),
                       SavingsData(dateLabel: "3 Oct", value: 300),
                       SavingsData(dateLabel: "4 Oct", value: 400),
                       SavingsData(dateLabel: "5 Oct", value: 500)]
    
    var chartData: [SavingsData] {
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

struct SavingsData: Identifiable {
    var id = UUID()
    let dateLabel: String
    let value: Double
}
