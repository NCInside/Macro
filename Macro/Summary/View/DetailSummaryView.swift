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
    let dateFormatter = DateFormatter()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    @StateObject private var viewModel = SummaryViewModel()
    @Query var journals: [Journal]
    @State var selectedWeek = 1
    
    @State var weekPoints: [Int: [Point]] = [:]
    @State var weekPointsPie: [Int: [PiePoint]] = [:]
    
    @State var selectedPoint: Point?
    
    var data: [Point] {
        viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth)
    }
    
    private var yAxisLabel: String {
        switch scenario {
        case .sleep: return "Total Tidur"
        case .fat: return "Total Lemak"
        case .dairy: return "Total Produk Susu"
        case .gi: return "Total Indeks Glikemik"
        }
    }
    
    private var descHeader: String {
        switch scenario {
        case .sleep:
            return "DI TEMPAT TIDUR"
        case .fat:
            return "MAKANAN BERLEMAK JENUH"
        case .dairy:
            return "KONSUMSI SUSU"
        case .gi:
            return ""
        }
    }
    
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
            case .fat:
                HStack {
                    Text("Makanan Berlemak")
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
                    
                    if let point = selectedPoint {
                        VStack(alignment: .leading) {
                            Text(descHeader)
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                                .bold()
                            HStack(alignment: .bottom) {
                                Text("\(point.value)")
                                    .font(.title2)
                                    .bold()
                                Text("\(scenario == .sleep ? "Jam" : "Kali")")
                                    .font(.caption)
                                Spacer()
                            }
                            Text("\(dateFormatter.string(from: point.date))")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                        }
                        .padding(.bottom, 12)
                    }
                    
                    if (scenario == .gi) {
                        if (viewModel.selectedTab == "Bulanan") {
                            Chart(viewModel.piePoints, id: \.category) { item in
                                SectorMark(
                                    angle: .value("Count", item.value)
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                                .annotation(position: .overlay, alignment: .center) {
                                    VStack {
                                        Text(item.category + " GI")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .bold()
                                        Text(String(item.value) + "x")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(.horizontal)
                        }
                        else {
                            Text("Week \(selectedWeek)")
                            Chart {
                                if weekPointsPie[selectedWeek] != nil {
                                    ForEach(viewModel.piePoints, id: \.category) { item in
                                        SectorMark(
                                            angle: .value("Count", item.value)
                                        )
                                        .foregroundStyle(by: .value("Category", item.category))
                                        .annotation(position: .overlay, alignment: .center) {
                                            VStack {
                                                Text(item.category + " GI")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .bold()
                                                Text(String(item.value) + "x")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .bold()
                                            }
                                        }
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
                                ForEach(data) { item in
                                    LineMark(x: .value("date", Calendar.current.component(.day, from: item.date)), y: .value("value", item.value))
                                        .foregroundStyle(Color.mint)
                                    
                                    PointMark(x: .value("date", Calendar.current.component(.day, from: item.date)), y: .value("value", item.value))
                                }
                            }
                            .chartYAxisLabel(yAxisLabel)
                            .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) {
                                AxisValueLabel()
                            }}
                            .chartXScale(domain: 0...Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: 2024, month: chosenMonth))!)!.count + 1)
                            .frame(maxHeight: 350)
                            .padding(.horizontal)
                            .chartYScale(domain: 0...10)
                            .chartOverlay { chart in
                                GeometryReader { geometry in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let currentX = value.location.x - geometry[chart.plotFrame!].origin.x
                                                    guard currentX >= 0, currentX < chart.plotSize.width else {
                                                        return
                                                    }
                                                    
                                                    // Calculate day based on the X position in the monthly chart (full month range)
                                                    let day = Int((currentX / chart.plotSize.width) * CGFloat(Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: 2024, month: chosenMonth))!)!.count))
                                                    
                                                    // Find the point corresponding to the calculated day
                                                    if let point = data.first(where: { Calendar.current.component(.day, from: $0.date) == day + 1 }) {
                                                        selectedPoint = point
                                                    }
                                                }
                                        )
                                }
                            }
                        }
                        else {
                            HStack {
                                Spacer()
                                Text("WEEK \(selectedWeek)")
                                    .bold()
                                Spacer()
                            }
                            
                            Chart {
                                if let week = weekPoints[selectedWeek] {
                                    ForEach(week) { item in
                                        let dayIndex = Calendar.current.component(.weekday, from: item.date) - 2
                                        let dayName = dayIndex >= 0 ? daysOfWeek[dayIndex] : daysOfWeek[dayIndex + 7]
                                        LineMark(x: .value("date", dayName), y: .value("value", item.value)) .foregroundStyle(Color.mint)
                                        
                                        PointMark(x: .value("date", Calendar.current.component(.day, from: item.date)), y: .value("value", item.value))
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) {
                                    AxisValueLabel()
                                }
                            }
                            .chartYAxisLabel(yAxisLabel)
                            .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) {
                                AxisValueLabel()
                            }}
                            
                            .frame(maxHeight: 350)
                            .chartYScale(domain: 0...10.8)
                            .padding(.horizontal)
                            .chartOverlay { chart in
                                GeometryReader { geometry in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let currentX = value.location.x - geometry[chart.plotFrame!].origin.x
                                                    guard currentX >= 0, currentX < chart.plotSize.width else {
                                                        return
                                                    }
                                                    
                                                    // Calculate day based on the X position in the weekly chart (7-day range)
                                                    let dayIndex = Int((currentX / chart.plotSize.width) * 7)  // 7 days in the week
                                                    
                                                    // Find the corresponding day name for the weekly chart
                                                    let selectedDay = daysOfWeek[dayIndex % 7]  // Ensure index is within bounds
                                                    
                                                    // Find the point for the corresponding day
                                                    if let point = weekPoints[selectedWeek]?.first(where: {
                                                        Calendar.current.component(.weekday, from: $0.date) == dayIndex + 2 // Adjust weekday to match
                                                    }) {
                                                        selectedPoint = point
                                                    }
                                                }
                                        )
                                }
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
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
            dateFormatter.dateFormat = "dd MMM yyyy"
            weekPoints = viewModel.getWeeks(of: viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth))
            weekPointsPie = viewModel.getWeeksPie(of: viewModel.piePoints)
        }
    }
}

#Preview {
    DetailSummaryView(scenario: .sleep , chosenMonth: 2)
}
