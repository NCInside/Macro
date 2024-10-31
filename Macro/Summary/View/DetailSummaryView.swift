//
//  DetailSummaryView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 17/10/24.
//

import SwiftUI
import Charts
import SwiftData

struct DetailSummaryView: View {
    
    var scenario: scenario
    var chosenMonth: Int
    let dayFormatter = DateFormatter()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    @StateObject private var viewModel = SummaryViewModel()
    @Query var journals: [Journal]
    @State var selectedWeek = 1
    @State var weekPoints: [Int: [Point]] = [:]
    @State var weekPointsPie: [Int: [PiePoint]] = [:]
    
    var body: some View {
        VStack(alignment: .leading) {
            switch scenario {
            case .sleep:
                HStack {
                    Text("Tidur")
                        .bold()
                        .font(.largeTitle)
                        .padding(.leading, 8)
                    Spacer()
                }
            case .protein:
                HStack {
                    Text("Protein")
                        .bold()
                        .font(.largeTitle)
                        .padding(.leading, 8)
                    Spacer()
                }
            case .fat:
                HStack {
                    Text("Lemak")
                        .bold()
                        .font(.largeTitle)
                        .padding(.leading, 8)
                    Spacer()
                }
            case .dairy:
                HStack {
                    Text("Produk Susu")
                        .bold()
                        .font(.largeTitle)
                        .padding(.leading, 8)
                    Spacer()
                }
            case .gi:
                HStack {
                    Text("Indeks Glikemik")
                        .bold()
                        .font(.largeTitle)
                        .padding(.leading, 8)
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                VStack {
                    Picker("Minggu/Bulan", selection: $viewModel.selectedTab) {
                        Text("Mingguan").tag("Mingguan")
                        Text("Bulanan").tag("Bulanan")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)
                    if (scenario == .gi) {
                        if (viewModel.selectedTab == "Bulanan") {
                            Chart(viewModel.piePoints, id: \.category) { item in
                                SectorMark(
                                    angle: .value("Count", item.value)
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                            }
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(.horizontal)
                        }
                        else {
                            Text("Week \(selectedWeek)")
                            Chart {
                                if let week = weekPointsPie[selectedWeek] {
                                    ForEach(viewModel.piePoints, id: \.category) { item in
                                        SectorMark(
                                            angle: .value("Count", item.value)
                                        )
                                        .foregroundStyle(by: .value("Category", item.category))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(.horizontal)
                            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                                .onEnded { value in
                                    switch(value.translation.width, value.translation.height) {
                                    case (...0, -30...30):
                                        print("left swipe")
                                        if selectedWeek < 5 {
                                            selectedWeek += 1
                                        }
                                    case (0..., -30...30):
                                        print("right swipe")
                                        if selectedWeek > 1 {
                                            selectedWeek -= 1
                                        }
                                    default:
                                        print("no clue")
                                    }
                                }
                            )
                        }
                    }
                    else {
                        if (viewModel.selectedTab == "Bulanan") {
                            Chart {
                                ForEach(viewModel.points) { item in
                                    BarMark(x: .value("date", Calendar.current.component(.day, from: item.date)), y: .value("value", item.value))
                                        .foregroundStyle(Color.mint)
                                }
                            }
                            .chartXScale(domain: 0...Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: 2024, month: chosenMonth))!)!.count + 1)
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(.horizontal)
                        }
                        else {
                            Text("Week \(selectedWeek)")
                            Chart {
                                if let week = weekPoints[selectedWeek] {
                                    ForEach(week) { item in
                                        let dayIndex = Calendar.current.component(.weekday, from: item.date) - 2
                                        let dayName = dayIndex >= 0 ? daysOfWeek[dayIndex] : daysOfWeek[dayIndex + 7]
                                        BarMark(x: .value("date", dayName), y: .value("value", item.value)) .foregroundStyle(Color.mint)
                                    }
                                }
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(.horizontal)
                            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                                .onEnded { value in
                                    switch(value.translation.width, value.translation.height) {
                                    case (...0, -30...30):
                                        print("left swipe")
                                        if selectedWeek < 5 {
                                            selectedWeek += 1
                                        }
                                    case (0..., -30...30):
                                        print("right swipe")
                                        if selectedWeek > 1 {
                                            selectedWeek -= 1
                                        }
                                    default:
                                        print("no clue")
                                    }
                                }
                            )
                        }
                    }
                    }
                    Spacer()
            }
                Spacer()
            }
            .onAppear {
                dayFormatter.dateFormat = "EEEE"
                viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth)
                weekPoints = viewModel.getWeeks(of: viewModel.points)
                weekPointsPie = viewModel.getWeeksPie(of: viewModel.piePoints)
            }
        }
    }

//#Preview {
//    DetailSummaryView(scenario: .sleep)
//}
