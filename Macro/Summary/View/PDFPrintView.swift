//
//  PDFPrintView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 25/10/24.
//


import SwiftUI
import Charts
import SwiftData

struct PDFPrintView: View {
    var chosenMonth: Int
    var chosenYear = Calendar.current.component(.year, from: Date())
    @StateObject private var viewModel = SummaryViewModel()
    
    @Query var journals: [Journal]
    @Environment(\.modelContext) var context
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    let age = UserDefaults.standard.string(forKey: "age") ?? "Unknown age"
    let gender = UserDefaults.standard.string(forKey: "gender") ?? "Unknown gender"
    let weight = UserDefaults.standard.string(forKey: "weight") ?? "Unknown weigth"
    let height = UserDefaults.standard.string(forKey: "height") ?? "Unknown heigth"
    
    var sleepPoints: [Point]
    var fatPoints: [Point]
    var dairyPoints: [Point]
    var giPoints: [PiePoint]
    var sleepData: [Int] { sleepPoints.map { $0.value } }
    var fatData: [Int] { fatPoints.map { $0.value } }
    var dairyData: [Int] { dairyPoints.map { $0.value }}
    
    var sleepRows: [TableRow] {
        sleepPoints.map { item in
            TableRow(date: viewModel.dateFormatter.string(from: item.date), value: String(item.value))
        }
    }
    var fatRows: [TableRow] {
        fatPoints.map { item in
            TableRow(date: viewModel.dateFormatter.string(from: item.date), value: String(item.value))
        }
    }
    var dairyRows: [TableRow] {
        dairyPoints.map { item in
            TableRow(date: viewModel.dateFormatter.string(from: item.date), value: String(item.value))
        }
    }
    var giRows: [GlycemicIndexRow] {
        // Group the giPoints by date
        let groupedByDate = Dictionary(grouping: giPoints) { Calendar.current.startOfDay(for: $0.date) }

        // Map the grouped data to an array of GlycemicIndexRow
        return groupedByDate.map { (date, points) in
            // Sum the `value` for each category within this date
            let lowSum = points.filter { $0.category == "Low" }.reduce(0) { $0 + $1.value }
            let mediumSum = points.filter { $0.category == "Medium" }.reduce(0) { $0 + $1.value }
            let highSum = points.filter { $0.category == "High" }.reduce(0) { $0 + $1.value }

            // Format the date and create a GlycemicIndexRow
            let formattedDate = viewModel.dateFormatter.string(from: date)
            
            return GlycemicIndexRow(
                date: formattedDate,
                low: String(lowSum),
                medium: String(mediumSum),
                high: String(highSum)
            )
        }
        // Sort rows by date if needed
        .sorted { $0.date < $1.date }
    }
    
    var body: some View {
                ScrollView{
        VStack (alignment: .leading) {
            VStack(alignment: .center) {
                Image("ZoraHeader")
                    .resizable()
                    .frame(width: 280, height: 55)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.main)
            .padding(.horizontal, -20)
            .padding(.bottom, 10)
            
            Text("Nama")
                .bold()
                .font(.title2)
                .padding(.bottom, 10)
            
            HStack{
                VStack(alignment: .leading){
                    Text("Usia : \(UserDefaults.standard.string(forKey: "age") ?? "not set") " )
                    
                    Text("Jenis Kelamin : \(UserDefaults.standard.string(forKey: "gender") ?? "not set") " )
                }
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("Berat Badan : \(UserDefaults.standard.string(forKey: "weight") ?? "not set")" )
                    
                    Text("Tinggi Badan : \(UserDefaults.standard.string(forKey: "height") ?? "not set")" )
                }
                .padding(.leading, 10)
            }
            .padding(.bottom, 10)
            
            Divider()
                .frame(minHeight: 3)
                .overlay(Color.gray.opacity(0.3))
                .padding(.bottom, 10)
            
            Text("Periode")
            
            HStack {
                Text("\(months[chosenMonth-1]) \(String(chosenYear))")
                    .bold()
                    .font(.title2)
                Spacer()
            }
            .padding(.bottom, 10)
            
            VStack {
                Text("Grafik Bulanan")
                    .padding(6)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.main)
            )
            .padding(.bottom, 16)
            
            
            Text("Tidur")
                .fontWeight(.semibold)
            
            Text("RERATA DI TEMPAT TIDUR")
                .font(.footnote)
                .foregroundColor(.gray)
                .fontWeight(.semibold)
            
            HStack(alignment: .bottom,spacing: 0) {
                Text("0")
                    .font(.largeTitle)
                    .bold()
                
                Text("jam ")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Text("0")
                    .font(.largeTitle)
                    .bold()
                
                Text("menit")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding(.bottom, 2)
                        
            Chart {ForEach(sleepData.indices, id: \.self) { index in LineMark( x: .value("Index", index), y: .value("Value", sleepData[sleepData.count - 1 - index]) )
                .foregroundStyle(Color.main) } }
                .frame(height: 220)
                .chartXAxis { AxisMarks(values: .stride(by: 10)) }
                .chartYScale(domain: 0...8.2)
                .chartYAxisLabel("Total Tidur")
                .padding(2)
                .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2))}
                .background(Color.white)
                .cornerRadius(10)
            
            Text("Makanan Berlemak")
                .fontWeight(.semibold)
            
            Text("RERATA MAKANAN BERLEMAK")
                .font(.footnote)
                .foregroundColor(.gray)
                .fontWeight(.semibold)
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("0")
                    .font(.largeTitle)
                    .bold()
                
                Text("kali")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding(.bottom, 2)
            
            Chart {ForEach(fatData.indices, id: \.self) { index in LineMark( x: .value("Index", index), y: .value("Value", fatData[fatData.count - 1 - index]) ) .foregroundStyle(Color.main) } }
                .frame(height: 220)
                .chartXAxis { AxisMarks(values: .stride(by: 10)) }
                .chartYScale(domain: 0...8.2)
                .chartYAxisLabel("Total Makanan Berlemak")
                .padding(2)
                .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) }
                .background(Color.white)
                .cornerRadius(10)
            
            Text("Lemak Jenuh")
                .fontWeight(.semibold)
            
            Text("Produk Susu")
                .fontWeight(.semibold)
            
            Text("RERATA KONSUMSI SUSU")
                .font(.footnote)
                .foregroundColor(.gray)
                .fontWeight(.semibold)
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("0")
                    .font(.largeTitle)
                    .bold()
                
                Text("kali")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            
            Chart {ForEach(dairyData.indices, id: \.self) { index in LineMark( x: .value("Index", index), y: .value("Value", dairyData[dairyData.count - 1 - index]) )
//                .chartYAxisLabel("Total Produk Susu")
                .foregroundStyle(Color.main) } }
                .frame(height: 220)
                .chartXAxis { AxisMarks(values: .stride(by: 10)) }
                .chartYScale(domain: 0...8.2)
                .padding(2)
                .chartYAxis { AxisMarks(position: .leading, values: .stride(by: 2)) }
                .background(Color.white)
                .cornerRadius(10)
            
            Text("Indeks Glikemik")
                .fontWeight(.semibold)
                .padding(.top)

            Chart(giPoints, id: \.category) { item in
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
            .frame(width: 250, height: 250)

            TableCard(
                title: "Riwayat Data Tidur",
                column2Header: "Lama Tidur",
                rows: sleepRows)
            
            TableCard(
                title: "Riwayat Data Makanan Berlemak",
                column2Header: "Jumlah Porsi",
                rows: fatRows,
                note: "(>5gr lemak jenuh)")
            
            TableCard(
                title: "Riwayat Data Produk Susu",
                column2Header: "Jumlah Porsi",
                rows: dairyRows,
                note: "(rekomendasi 1 porsi)")
            
            GlycemicCard(
                title: "Riwayat Data Indeks Glikemik",
                rows: giRows
            )
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .background(Color.white)
                }
    }
}

struct PDFPrintView_Previews: PreviewProvider {
    static var previews: some View {
        PDFPrintView(
            chosenMonth: 1,
            sleepPoints: [
                            Point(date: Date(), value: 7),
                            Point(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, value: 6),
                            Point(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, value: 8),
                            Point(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, value: 6),
                            Point(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, value: 8),
                            Point(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, value: 6),
                            Point(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, value: 8),
                            Point(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, value: 6),
                            Point(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, value: 8),
                            Point(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, value: 6),
                            Point(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, value: 8),
                            Point(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, value: 6),
                            Point(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, value: 8),
                            Point(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, value: 5)
                        ],
            fatPoints: [Point(date: Date(), value: 7),
                        Point(date: Date().addingTimeInterval(-6400), value: 6),
                        Point(date: Date().addingTimeInterval(-6400), value: 4)],
            dairyPoints: [Point(date: Date(), value: 1), Point(date: Date().addingTimeInterval(-86400), value: 2)],
            giPoints: [PiePoint(date: Date(), category: "Low", value: 2), PiePoint(date: Date(), category: "High", value: 3)]
        )
    }
}

