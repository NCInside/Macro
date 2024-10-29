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
    @State var protein: Double = 0
    @State var fat: Double = 0
    
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
                }
                
                Picker("Month", selection: $chosenMonth) {
                    ForEach(1..<months.count + 1, id: \.self) { index in
                        Text(months[index - 1]).tag(index)
                    }
                }
                .padding(.leading, -12)
                .onChange(of: chosenMonth) {
                    viewModel.updateValue(journals: journals, chosenMonth: chosenMonth)
                }

                
                ScrollView {
                    VStack {
                        NavigationLink(destination: DetailSummaryView(scenario: .sleep, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Tidur",
                                caption: "Rerata waktu terlelap",
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
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .fat, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Lemak",
                                caption: "Rerata konsumsi lemak",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.avgFat))
                                        .font(.title)
                                        .bold()
                                    Text("/\(String(format: "%.2f", fat))gram")
                                        .font(.caption2)
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .dairy, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Produk Susu",
                                caption: "Frekuensi",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.freqMilk))
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("x")
                                        .font(.caption2)
                                })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: DetailSummaryView(scenario: .gi, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Indeks Glikemik",
                                caption: "Rerata indeks",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(viewModel.ind)
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                })
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
            //generateDummy()
            viewModel.updateValue(journals: journals, chosenMonth: chosenMonth)
            let energyExpenditure = viewModel.calcEnergyExpenditure()
            fat = energyExpenditure * 0.2 / 9
        }
    }
    
}

#Preview {
    SummaryView()
}
