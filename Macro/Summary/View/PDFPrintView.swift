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
    @State var chosenMonth = Calendar.current.component(.month, from: Date())
    @State var protein: Double = 0
    @State var fat: Double = 0
    
    @StateObject private var viewModel = SummaryViewModel()
    @Environment(\.modelContext) var context
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Ringkasan \(months[chosenMonth])")
                    .bold()
                    .font(.largeTitle)
                Spacer()
            }
            
            VStack {
                SummaryCard(
                    title: "Tidur",
                    caption: "Rerata waktu terlelap",
                    detail: HStack (alignment: .bottom,spacing: 0) {
                        Text(String(viewModel.avgSleep / 3600))
                            .font(.title)
                            .bold()
                        Text("jam")
                            .font(.caption2)
                            .padding(.trailing, 4)
                        Text(String((viewModel.avgSleep % 3600) / 60))
                            .font(.title)
                            .bold()
                        Text("menit")
                            .font(.caption2)
                    },
                    showChevron: false)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SummaryCard(
                    title: "Protein",
                    caption: "Rerata konsumsi protein",
                    detail: HStack (alignment: .bottom,spacing: 0) {
                        Text(String(viewModel.avgProtein))
                            .font(.title)
                            .bold()
                        Text("/\(String(format: "%.2f", protein))gram")
                            .font(.caption2)
                    },
                    showChevron: false)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SummaryCard(
                    title: "Lemak",
                    caption: "Rerata konsumsi lemak",
                    detail: HStack (alignment: .bottom,spacing: 0) {
                        Text(String(viewModel.avgFat))
                            .font(.title)
                            .bold()
                        Text("/\(String(format: "%.2f", fat))gram")
                            .font(.caption2)
                    },
                    showChevron: false)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SummaryCard(
                    title: "Produk Susu",
                    caption: "Frekuensi",
                    detail: HStack (alignment: .bottom,spacing: 0) {
                        Text(String(viewModel.freqMilk))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .bold()
                        Text("x")
                            .font(.caption2)
                    },
                    showChevron: false)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SummaryCard(
                    title: "Indeks Glikemik",
                    caption: "Rerata indeks",
                    detail: HStack (alignment: .bottom,spacing: 0) {
                        Text(viewModel.ind)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .bold()
                    },
                    showChevron: false)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .background(Color.background)
    }
}

#Preview {
    PDFPrintView()
}
