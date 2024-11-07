//
//  SummaryView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 17/10/24.
//

import SwiftUI
import SwiftData

struct SummaryView: View {
    
    @StateObject private var viewModel = SummaryViewModel()
    @Environment(\.modelContext) var context
    @Query var journals: [Journal]
    @State var chosenMonth = Calendar.current.component(.month, from: Date())
    @State var saturatedFat: Double = 0
    
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading) {
                HStack {
                    Text("Ringkasan")
                        .bold()
                        .font(.largeTitle)
                    Spacer()
                    
                    ShareLink("Export PDF", item: render())
                }
                
                Menu {
                    ForEach(1..<months.count + 1, id: \.self) { index in
                        Button(months[index - 1]) {
                            chosenMonth = index
                            viewModel.updateValue(journals: journals, chosenMonth: chosenMonth)
                        }
                    }
                } label: {
                    Text(months[chosenMonth - 1])
                        .foregroundColor(.black)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Image(systemName: "chevron.down")
                        .padding(.trailing, -10)
                }
                
                
                
                ScrollView {
                    VStack {
                        NavigationLink(destination: DetailSummaryView(scenario: .sleep, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Tidur",
                                caption: "Rerata waktu tidur harian",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.avgSleep / 3600))
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("jam")
                                        .font(.caption2)
                                        .padding(.trailing, 4)
                                    Text(String((viewModel.avgSleep % 3600) / 60))
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("menit")
                                        .font(.caption2)
                                },
                                icon: "Sleep",
                                iconSize: CGSize(width: 80, height: 100),
                                iconPadding: EdgeInsets(top: 0, leading: 10, bottom: -45, trailing: -5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .fat, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Makanan Berlemak",
                                caption: "Rerata frekuensi harian",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.avgFat))
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("porsi")
                                        .font(.caption2)
                                },
                                icon: "DrumStickFull",
                                iconSize: CGSize(width: 100, height: 95),
                                iconPadding: EdgeInsets(top: 0, leading: 0, bottom: -50, trailing: -6))
                            
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .saturatedFat, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Lemak Jenuh",
                                caption: "Rerata frekuensi harian",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.avgSaturatedFat))
                                        .font(.title)
                                        .bold()
                                    Text("/\(String(format: "%.2f", saturatedFat))gram")
                                        .font(.caption2)
                                },
                                icon: "BurgerFull",
                                iconSize: CGSize(width: 100, height: 90),
                                iconPadding: EdgeInsets(top: 0, leading: 0, bottom: -50, trailing: -6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .dairy, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Produk Susu",
                                caption: "Rerata frekuensi harian",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.freqMilk))
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("/1 porsi")
                                        .font(.caption2)
                                },
                                icon: "Milk",
                                iconSize: CGSize(width: 70, height: 100),
                                iconPadding: EdgeInsets(top: 0, leading: 0, bottom: -50, trailing: 10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .gi, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Indeks Glikemik",
                                caption: "Kategori Indeks Terbanyak",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(viewModel.ind)
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                },
                                icon: "Donut",
                                iconSize: CGSize(width: 90, height: 90),
                                iconPadding: EdgeInsets(top: 0, leading: 0, bottom: -45, trailing: 0))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .padding(.horizontal)
            .background(Color.background)
        }
        .onAppear {
//            generateDummy()
            viewModel.updateValue(journals: journals, chosenMonth: chosenMonth)
            let energyExpenditure = viewModel.calcEnergyExpenditure()
            saturatedFat = energyExpenditure * 0.2 / 9
        }
    }
    
    private func render() -> URL {
        
        let sleepPoints = fetchPoints(for: .sleep)
        let fatPoints = fetchPoints(for: .fat)
        let saturatedFatPoints = fetchPoints(for: .saturatedFat)
        let dairyPoints = fetchPoints(for: .dairy)
        let giPoints = viewModel.getGIPoints(journals: journals, chosenMonth: chosenMonth)
                
        // 1: Render Hello World with some modifiers
        let renderer = ImageRenderer(
            content: PDFPrintView(chosenMonth: chosenMonth,
                                  sleepPoints: sleepPoints,
                                  fatPoints: fatPoints,
                                  saturatedFatPoints: saturatedFatPoints,
                                  dairyPoints: dairyPoints,
                                  giPoints: giPoints))
        
        // 2: Save it to our documents directory
        let url = URL.documentsDirectory.appending(path: "\(chosenMonth) Summary - \(UserDefaults.standard.string(forKey: "name") ?? "Unknown").pdf")
        
        // 3: Start the rendering process
        renderer.render { size, context in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 5: Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            // 6: Start a new PDF page
            pdf.beginPDFPage(nil)
            
            // 7: Render the SwiftUI view data onto the page
            context(pdf)
            
            // 8: End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        return url
    }
    
    private func fetchPoints(for scenario: scenario) -> [Point] {
        let sortedPoints = viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth).sorted { $0.date < $1.date }
        return sortedPoints
    }
    
}

#Preview {
    SummaryView()
}
