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
    var saturatedFatPoints: [Point]
    var dairyPoints: [Point]
    var giPoints: [PiePoint]
    
    var sleepData: [Int] { sleepPoints.map { $0.value } }
    var fatData: [Int] { fatPoints.map { $0.value } }
    var saturatedFatData: [Int] { saturatedFatPoints.map { $0.value } }
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
    var saturatedFatRows: [TableRow] {
        saturatedFatPoints.map { item in
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
        //        ScrollView{
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
                        
            Chart {ForEach(sleepData.indices, id: \.self) { index in BarMark( x: .value("Index", index), y: .value("Value", sleepData[sleepData.count - 1 - index]) ) .foregroundStyle(Color.blue) } }
                .chartXAxis { AxisMarks(values: .stride(by: 1)) }
                .chartYAxis { AxisMarks(values: .stride(by: 1)) }
                .frame(height: 120) .background(Color.black)
                .cornerRadius(10)
            
            Text("Makanan Berlemak")
                .fontWeight(.semibold)
            
            Chart {ForEach(fatData.indices, id: \.self) { index in BarMark( x: .value("Index", index), y: .value("Value", fatData[fatData.count - 1 - index]) ) .foregroundStyle(Color.blue) } }
                .chartXAxis { AxisMarks(values: .stride(by: 1)) }
                .chartYAxis { AxisMarks(values: .stride(by: 1)) }
                .frame(height: 120) .background(Color.black)
                .cornerRadius(10)
            
            Text("Lemak Jenuh")
                .fontWeight(.semibold)
            
            Chart {ForEach(saturatedFatData.indices, id: \.self) { index in BarMark( x: .value("Index", index), y: .value("Value", saturatedFatData[saturatedFatData.count - 1 - index]) ) .foregroundStyle(Color.blue) } }
                .chartXAxis { AxisMarks(values: .stride(by: 1)) }
                .chartYAxis { AxisMarks(values: .stride(by: 1)) }
                .frame(height: 120) .background(Color.black)
                .cornerRadius(10)
            
            Text("Produk Susu")
                .fontWeight(.semibold)
            
            Chart {ForEach(dairyData.indices, id: \.self) { index in BarMark( x: .value("Index", index), y: .value("Value", dairyData[dairyData.count - 1 - index]) ) .foregroundStyle(Color.blue) } }
                .chartXAxis { AxisMarks(values: .stride(by: 1)) }
                .chartYAxis { AxisMarks(values: .stride(by: 1)) }
                .frame(height: 120) .background(Color.black)
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
                title: "Riwayat Data Lemak Jenuh",
                column2Header: "Komposisi Lemak Jenuh",
                rows: saturatedFatRows,
                note: "(rekomendasi <17 gram)")
            
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
        .background(Color.background)
        //        }
    }
}

//#Preview {
//    PDFPrintView(chosenMonth: 1)
//}
