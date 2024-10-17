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
                    ForEach(1..<13) { monthIndex in
                        Text(months[monthIndex - 1])
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
                        NavigationLink(destination: DetailSummaryView(scenario: .protein, chosenMonth: chosenMonth)) {
                            SummaryCard(
                                title: "Protein",
                                caption: "Rerata konsumsi protein",
                                detail: HStack (alignment: .bottom,spacing: 0) {
                                    Text(String(viewModel.avgProtein))
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .bold()
                                    Text("gram")
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
                                    Text("gram")
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
            .background(.gray)
        }
        .onAppear {
            //generateDummy()
            viewModel.updateValue(journals: journals, chosenMonth: chosenMonth)
        }
    }
    
    private func generateDummy() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!
        
        let todayFoods = [
            Food(timestamp: today, name: "Steak", protein: 27.12, fat: 12.34, glycemicIndex: .low, dairy: false),
            Food(timestamp: today, name: "Rice", protein: 10.22, fat: 3.58, glycemicIndex: .medium, dairy: false),
            Food(timestamp: today, name: "Milk", protein: 8.37, fat: 7.53, glycemicIndex: .low, dairy: true)
        ]
        let yesterdayFoods = [
            Food(timestamp: yesterday, name: "Apple", protein: 1.12, fat: 0.25, glycemicIndex: .medium, dairy: false),
            Food(timestamp: yesterday, name: "Pasta", protein: 7.91, fat: 2.79, glycemicIndex: .high, dairy: false),
            Food(timestamp: yesterday, name: "Yogurt", protein: 9.15, fat: 4.92, glycemicIndex: .low, dairy: true)
        ]
        let dayBeforeYesterdayFoods = [
            Food(timestamp: dayBeforeYesterday, name: "Bread", protein: 6.54, fat: 2.78, glycemicIndex: .medium, dairy: false),
            Food(timestamp: dayBeforeYesterday, name: "Chicken", protein: 23.17, fat: 8.66, glycemicIndex: .low, dairy: false),
            Food(timestamp: dayBeforeYesterday, name: "Banana", protein: 1.29, fat: 0.33, glycemicIndex: .high, dairy: false)
        ]
        
        let todaySleep = Sleep(timestamp: today, duration: 8*3600)
        let yesterdaySleep = Sleep(timestamp: yesterday, duration: 6*3600)
        let dayBeforeYesterdaySleep = Sleep(timestamp: dayBeforeYesterday, duration: 5*3600)
        
        let todayJournal = Journal(timestamp: today, foods: todayFoods, sleep: todaySleep)
        let yesterdayJournal = Journal(timestamp: yesterday, foods: yesterdayFoods, sleep: yesterdaySleep)
        let dayBeforeYesterdayJournal = Journal(timestamp: dayBeforeYesterday, foods: dayBeforeYesterdayFoods, sleep: dayBeforeYesterdaySleep)
        
        context.insert(todayJournal)
        context.insert(yesterdayJournal)
        context.insert(dayBeforeYesterdayJournal)
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    SummaryView()
}
