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
    let weekFormatter = DateFormatter()
    let daysOfWeek = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    let categoryColors: [String: Color] = [
        "Low": Color.mainLight.opacity(0.5),
        "Medium": Color.mainLight,
        "High": Color.main
    ]
    
    @StateObject private var viewModel = SummaryViewModel()
    @Query var journals: [Journal]
    @Query var journalImage: [JournalImage]
    @State var selectedWeek = 1
    
    @State var weekPoints: [Int: [Point]] = [:]
    @State var weekPointsPie: [Int: [PiePoint]] = [:]
    
    @State var selectedPoint: Point?
    @State private var xPosition: CGFloat = 0
    
    var maxWeekInMonth: Int? {
        let calendar = Calendar.current
            
        let components = DateComponents(year: 2024, month: chosenMonth, day: 1)
        guard let startOfMonth = calendar.date(from: components) else {
            return nil
        }
        
        let range = calendar.range(of: .weekOfMonth, in: .month, for: startOfMonth)
        
        return range?.count
    }
    
    
    var daysToFirstDateOfFirstWeek: Int? {
        let calendar = Calendar.current
        
        let components = DateComponents(year: 2024, month: chosenMonth, day: 1)
        guard let startOfMonth = calendar.date(from: components) else {
            return nil
        }
        
        let firstWeekdayOfMonth = calendar.component(.weekday, from: startOfMonth)
        
        let calendarFirstWeekday = calendar.firstWeekday
        
        let daysNeeded = (firstWeekdayOfMonth - calendarFirstWeekday + 7) % 7

        return daysNeeded
    }
    
    var data: [Point] {
        viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth).sorted(by: { $0.date < $1.date })
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
                    Text("Makanan Berlemak Jenuh")
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
                                }
                                Text("\(dateFormatter.string(from: point.date))")
                                    .foregroundStyle(.gray)
                                    .font(.subheadline)
                            }
                            .padding(6)
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                            .offset(x: xPosition - 167)
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
                                .padding(.bottom, 1)
                                if viewModel.selectedTab == "Bulanan" {
                                    Text("1 \(months[chosenMonth - 1]) - \(lastDay(ofMonth: chosenMonth, year: 2024)) \(months[chosenMonth - 1]) 2024")
                                        .foregroundStyle(.gray)
                                        .font(.subheadline)
                                }
                                else {
                                    Text("\(weekFormatter.string(from: getFirstAndLastDateOfWeek(week: selectedWeek, month: chosenMonth, year: 2024).firstDate ?? Date())) - \(weekFormatter.string(from: getFirstAndLastDateOfWeek(week: selectedWeek, month: chosenMonth, year: 2024).lastDate ?? Date()))")
                                        .foregroundStyle(.gray)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                    
                    if (scenario == .gi) {
                        if (viewModel.selectedTab == "Bulanan") {
                            Chart(viewModel.aggregatedPiePoints(), id: \.category) { item in
                                SectorMark(
                                    angle: .value("Count", item.value),
                                    innerRadius: .ratio(0.6)
                                )
                                .foregroundStyle(categoryColors[item.category] ?? Color.gray)
                                .annotation(position: .overlay, alignment: .center) {
                                    VStack {
                                        Text(item.category + " GI")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .bold()
                                        Text(String(item.value) + "x")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(.horizontal)
                        }
                        else {
                            Text("Minggu ke-\(selectedWeek)")
                                .bold()
                            VStack(alignment: .leading) {
                                Chart {
                                    let calendar = Calendar.current
                                    let weekStartDate = calendar.date(from: DateComponents(year: 2024, month: chosenMonth, weekOfMonth: selectedWeek))!
                                    let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStartDate) }
                                    
                                    ForEach(weekDates, id: \.self) { date in
                                        let dayIndex = calendar.component(.weekday, from: date)
                                        let indexDay = (dayIndex + 12 - (daysToFirstDateOfFirstWeek ?? 0)) % 7
                                        let dayName = daysOfWeek[indexDay]
                                        
                                        // Find items for the current day
                                        let itemsForDay = weekPointsPie[selectedWeek]?.filter {
                                            (Calendar.current.component(.weekday, from: $0.date) + (daysToFirstDateOfFirstWeek ?? 0)) % 7 == dayIndex
                                        } ?? []
                                        
                                        // Flag to check if we have data for the current day
                                        let hasData = !itemsForDay.isEmpty

                                        // Show BarMark for each item on this day if data exists
                                        ForEach(itemsForDay) { item in
                                            BarMark(x: .value("date", dayName), y: .value("value", item.value))
                                                .position(by: .value("Category", item.category))
                                                .foregroundStyle(categoryColors[item.category] ?? Color.gray)
                                        }
                                        
                                        if !hasData {
                                            BarMark(x: .value("date", dayName), y: .value("value", 0))
                                        }
                                    }
                                }
                                
                                HStack {
                                    Circle()
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(.mainLight.opacity(0.5))
                                    Text("Indeks Rendah")
                                        .bold()
                                }
                                .padding(.top)
                                HStack {
                                    Circle()
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(.mainLight)
                                    Text("Indeks Sedang")
                                        .bold()
                                }
                                HStack {
                                    Circle()
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(.main)
                                    Text("Indeks Tinggi")
                                        .bold()
                                }
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(16)
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                                .onEnded { value in
                                    switch(value.translation.width, value.translation.height) {
                                    case (...0, -30...30):
                                        if selectedWeek < maxWeekInMonth ?? 5 {
                                            selectedWeek += 1
                                        }
                                    case (0..., -30...30):
                                        if selectedWeek > 1 {
                                            selectedWeek -= 1
                                        }
                                    default:
                                        print("no clue")
                                    }
                                }
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Info terkait Indeks Glikemik (IG)")
                                .foregroundStyle(Color.mainLight)
                                .font(.headline)
                            Text("Indeks Glikemik (IG) adalah indikator yang menunjukkan seberapa cepat makanan yang mengandung karbohidrat meningkatkan kadar gula darah dalam tubuh. Indeks glikemik diukur menggunakan skala 0–100, dengan kategori sebagai berikut: Indeks glikemik rendah: di bawah 55, Indeks glikemik sedang: 56–69, Indeks glikemik tinggi: di atas 70.")
                                .padding(.top, 6)
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                        .padding(.top, 12)
                        
                    }
                    else {
                        if (viewModel.selectedTab == "Bulanan") {
                            ZStack {
                                VStack(alignment: .leading) {
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
                                    .chartYAxisLabel(yAxisLabel)
                                    .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) {
                                        AxisValueLabel()
                                    }}
                                    .chartXScale(domain: 0...Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: 2024, month: chosenMonth))!)!.count + 1)
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
                                            
                                            if selectedPoint != nil {
                                                Path { path in
                                                    let chartTopY = geometry[chart.plotFrame!].origin.y
                                                    let chartBottomY = geometry[chart.plotFrame!].origin.y + geometry[chart.plotFrame!].size.height
                                                    path.move(to: CGPoint(x: xPosition + 15, y: chartTopY - 10 ))
                                                    path.addLine(to: CGPoint(x: xPosition + 15, y: chartBottomY + 10))
                                                }
                                                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                                .offset(y: -20)
                                            }
                                            
                                        }
                                    }
                                    
                                    HStack {
                                        Circle()
                                            .foregroundStyle(Color.red)
                                            .frame(width: 12)
                                        Text("BREAKOUT")
                                            .bold()
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(.leading, 8)
                                    .padding(.top, 12)
                                }
                                .frame(maxHeight: 350)
                                .padding(.horizontal)
                                
                            }
                        }
                        else {
                            ZStack {
                                VStack {
                                    Chart {
                                        let calendar = Calendar.current
                                        let weekStartDate = calendar.date(from: DateComponents(year: 2024, month: chosenMonth, weekOfMonth: selectedWeek))!
                                        let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStartDate) }
                                        
                                        ForEach(weekDates, id: \.self) { date in
                                                                                    
                                            let dayIndex = calendar.component(.weekday, from: date)
                                            let indexDay = (dayIndex + 12 - (daysToFirstDateOfFirstWeek ?? 0)) % 7
                                            let dayName = daysOfWeek[indexDay]
                                            
                                            LineMark(x: .value("date", dayName),
                                                     y: .value("value", 0),
                                                     series: .value("PLC", "A")
                                            )
                                                .foregroundStyle(Color.gray.opacity(0))

                                            if let item = weekPoints[selectedWeek]?.first(where: {
                                                let pointDayIndex = (Calendar.current.component(.weekday, from: $0.date) + (daysToFirstDateOfFirstWeek ?? 0)) % 7
                                                return pointDayIndex == dayIndex
                                            }) {
                                                LineMark(x: .value("date", dayName),
                                                         y: .value("value", item.value),
                                                         series: .value("REAL", "B")
                                                )
                                                    .foregroundStyle(Color.main)
                                                
                                                if viewModel.hasBreakoutImage(on: item.date, in: journalImage) {
                                                    PointMark(x: .value("date", dayName), y: .value("value", item.value))
                                                        .foregroundStyle(Color.red)
                                                }
                                            }
                                        }
                                    }
                                    .chartYAxisLabel(yAxisLabel)
                                    .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) {
                                        AxisValueLabel()
                                    }}
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

                                                            // Calculate the position as a fraction of the chart width
                                                            let fraction = currentX / chart.plotSize.width

                                                            // Calculate the day index based on the fraction (7 days in a week)
                                                            let dayIndex = Int(fraction * 7)

                                                            // Find the corresponding point in `weekPoints`
                                                            if let point = weekPoints[selectedWeek]?.first(where: {
                                                                let pointDayIndex = Calendar.current.component(.weekday, from: $0.date) - 1
                                                                return pointDayIndex == dayIndex
                                                            }) {
                                                                selectedPoint = point
                                                            }
                                                        }
                                                )
                                            
                                            if selectedPoint != nil {
                                                Path { path in
                                                    let chartTopY = geometry[chart.plotFrame!].origin.y
                                                    let chartBottomY = geometry[chart.plotFrame!].origin.y + geometry[chart.plotFrame!].size.height
                                                    path.move(to: CGPoint(x: xPosition + 15, y: chartTopY - 10 ))
                                                    path.addLine(to: CGPoint(x: xPosition + 15, y: chartBottomY + 10))
                                                }
                                                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                                .offset(y: -20)
                                            }
                                        }
                                    }
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 20.0, coordinateSpace: .local)
                                            .onEnded { value in
                                                // Use the predicted end location to assess the swipe acceleration.
                                                let predictedWidth = value.predictedEndTranslation.width
                                                let threshold: CGFloat = 240  // Adjust as needed for sensitivity

                                                // Determine swipe direction and acceleration, adjusting by one week if the threshold is exceeded.
                                                if predictedWidth < -threshold && selectedWeek < maxWeekInMonth ?? 5 {
                                                    // Swipe left with acceleration
                                                    selectedWeek += 1
                                                } else if predictedWidth > threshold && selectedWeek > 1 {
                                                    // Swipe right with acceleration
                                                    selectedWeek -= 1
                                                } else {
                                                    print("no clue")
                                                }
                                            }
                                    )
                                    
                                    HStack {
                                        Circle()
                                            .foregroundStyle(Color.red)
                                            .frame(width: 12)
                                        Text("BREAKOUT")
                                            .bold()
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(.leading, 8)
                                    .padding(.top, 12)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 350)
                                .padding(.horizontal)
                            }
                                                                            
                            HStack {
                                Spacer()
                                Text("Minggu ke-\(selectedWeek)")
                                    .bold()
                                Spacer()
                            }
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .background(Color.systemGray2)
        .onAppear {
            dayFormatter.dateFormat = "EEEE"
            dateFormatter.dateFormat = "dd MMM yyyy"
            weekFormatter.dateFormat = "dd MMM"
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
    
    func getFirstAndLastDateOfWeek(week: Int, month: Int, year: Int) -> (firstDate: Date?, lastDate: Date?) {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.weekOfMonth = week
        components.weekday = calendar.firstWeekday  // typically Sunday or Monday, depending on the locale

        // Get the first date of the week
        guard let firstDate = calendar.date(from: components) else {
            return (nil, nil)
        }

        // Get the last date of the week by adding 6 days to the first date
        let lastDate = calendar.date(byAdding: .day, value: 6, to: firstDate)

        return (firstDate, lastDate)
    }
}

#Preview {
    DetailSummaryView(scenario: .sleep , chosenMonth: 2, average: 3660)
}
