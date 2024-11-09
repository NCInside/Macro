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
    var average: Int
    let dayFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    @StateObject private var viewModel = SummaryViewModel()
    @Query var journals: [Journal]
    @Query var journalImage: [JournalImage]
    @State var selectedWeek = 1
    
    @State var weekPoints: [Int: [Point]] = [:]
    @State var weekPointsPie: [Int: [PiePoint]] = [:]
    
    @State var selectedPoint: Point?
    @State private var xPosition: CGFloat = 0
    
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
                    .onChange(of: viewModel.selectedTab) { oldValue, newValue in
                        selectedPoint = nil
                    }
                    
                    
                    if (scenario != .gi) {
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
                            .offset(x: xPosition - 25)
                            .onTapGesture {
                                selectedPoint = nil
                            }
                        }
                        else {
                            VStack(alignment: .leading) {
                                Text("RERATA " + descHeader)
                                    .foregroundStyle(.gray)
                                    .font(.subheadline)
                                    .bold()
                                HStack(alignment: .bottom) {
                                    Text("\(String(scenario == .sleep ? average / 3600 : average))")
                                        .font(.title2)
                                        .bold()
                                    Text("\(scenario == .sleep ? "Jam" : "Kali")")
                                        .font(.caption)
                                    if scenario == .sleep {
                                        Text("\(String((average % 3600) / 60))")
                                            .font(.title2)
                                            .bold()
                                        Text("Menit")
                                            .font(.caption)
                                    }
                                    Spacer()
                                }
                                Text("1 \(months[chosenMonth - 1]) - \(lastDay(ofMonth: chosenMonth, year: 2024)) \(months[chosenMonth - 1]) 2024")
                                    .foregroundStyle(.gray)
                                    .font(.subheadline)
                            }
                            .padding(.bottom, 12)
                        }
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
                                if let week = weekPointsPie[selectedWeek] {
                                    ForEach(week) { item in
                                        let dayIndex = Calendar.current.component(.weekday, from: item.date) - 2
                                        let dayName = dayIndex >= 0 ? daysOfWeek[dayIndex] : daysOfWeek[dayIndex + 7]
                                        BarMark(x: .value("date", dayName), y: .value("value", item.value)) 
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
                            ZStack {
                                Chart {
                                    ForEach(data) { item in
                                        LineMark(x: .value("date", Calendar.current.component(.day, from: item.date)), y: .value("value", item.value))
                                            .foregroundStyle(Color.main)
                                        
                                        if viewModel.hasBreakoutImage(on: item.date, in: journalImage) {
                                            PointMark(x: .value("date", Calendar.current.component(.day, from: item.date)), y: .value("value", item.value))
                                                .foregroundStyle(Color.red)
                                        }
                                    }
                                }
                                .offset(y: selectedPoint != nil ? -100 : 7)
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
                                                        
                                                        xPosition = currentX
                                                        
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
                                
                                if selectedPoint != nil {
                                    Path { path in
                                        path.move(to: CGPoint(x: xPosition + 30, y: -25))
                                        path.addLine(to: CGPoint(x: xPosition + 30, y: 340))  // Line down to chart bottom
                                    }
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                    .offset(y: 20)
                                }
                            }
                        }
                        else {
                            ZStack {
                                Chart {
                                    if let week = weekPoints[selectedWeek] {
                                        ForEach(week) { item in
                                            let dayIndex = Calendar.current.component(.weekday, from: item.date) - 2
                                            let dayName = dayIndex >= 0 ? daysOfWeek[dayIndex] : daysOfWeek[dayIndex + 7]
                                            LineMark(x: .value("date", dayName), y: .value("value", item.value)) .foregroundStyle(Color.main)
                                            
                                            if viewModel.hasBreakoutImage(on: item.date, in: journalImage) {
                                                PointMark(x: .value("date", dayName), y: .value("value", item.value))
                                                    .foregroundStyle(Color.red)
                                            }
                                        }
                                    }
                                    
                                }
                                .offset(y: selectedPoint != nil ? -100 : -7)
                                .chartYAxisLabel(yAxisLabel)
                                .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) {
                                    AxisValueLabel()
                                }}
                                .frame(maxWidth: .infinity, maxHeight: 350)
                                .padding(.horizontal)
                                .chartYScale(domain: 0...10.8)
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
                                                        
                                                        xPosition = currentX
                                                        
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
                                
                                if selectedPoint != nil {
                                    Path { path in
                                        path.move(to: CGPoint(x: xPosition + 30, y: -25))
                                        path.addLine(to: CGPoint(x: xPosition + 30, y: 340))  // Line down to chart bottom
                                    }
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                    .offset(y: 20)
                                }
                            }
                                                                            
                            HStack {
                                Spacer()
                                Text("WEEK \(selectedWeek)")
                                    .bold()
                                Spacer()
                            }
                            .offset(y: selectedPoint != nil ? -187 : 0)
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            print(journalImage)
            dayFormatter.dateFormat = "EEEE"
            dateFormatter.dateFormat = "dd MMM yyyy"
            weekPoints = viewModel.getWeeks(of: viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth))
            weekPointsPie = viewModel.getWeeksPie(of: viewModel.piePoints)
        }
    }
    
    func lastDay(ofMonth m: Int, year y: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return cal.component(.day, from: date)
    }
}

#Preview {
    DetailSummaryView(scenario: .sleep , chosenMonth: 2, average: 3660)
}
