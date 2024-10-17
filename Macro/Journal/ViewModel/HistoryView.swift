//
//  HistoryView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.editMode) private var editMode
    @Query private var journals: [Journal]
    @State private var historyOption = "Diet"
    private var options = ["Diet", "Sleep"]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("History", selection: $historyOption) {
                    ForEach(options, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    VStack(alignment: .leading) {
                        
                        ForEach(journals.sorted { $0.timestamp > $1.timestamp }, id: \.self) { journal in
                            if historyOption == "Diet" {
                                
                                HStack {
                                    Text("\(journal.timestamp, formatter: dateFormatter)")
                                        .font(.callout)
                                    Spacer()
                                    
                                }
                                .padding(.leading, 24)
                                
                                VStack(spacing: 0) {
                                    ForEach(journal.foods, id: \.self) { food in
                                        NavigationLink(destination: FoodDetailHistoryView(food: food)) {
                                            HStack {
                                                if editMode?.wrappedValue == .active {
                                                    Image(systemName: "minus.circle")
                                                        .foregroundColor(.white)
                                                        .background(.red)
                                                        .clipShape(Circle())
                                                        .padding(.leading)
                                                        .onTapGesture {
                                                            deleteFood(food: food)
                                                        }
                                                    Text(food.name)
                                                        .padding(.vertical, 10)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundStyle(.black)
                                                    Text("Detail")
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing)
                                                } else {
                                                    Text(food.name)
                                                        .padding(.vertical, 10)
                                                        .padding(.horizontal)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundStyle(.black)
                                                    Text("Detail")
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                if !(editMode?.wrappedValue == .active) {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing)
                                                }
                                            }
                                            .background(Color(UIColor.systemBackground))
                                        }
                                        Divider()
                                            .padding(.leading)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                                
                            } else {
                                
                                HStack {
                                    Text("\(Calendar.current.date(byAdding: .day, value: -1, to: journal.timestamp) ?? Date(), formatter: dateFormatter) - \(journal.timestamp, formatter: dateFormatter)")
                                        .font(.callout)
                                    Spacer()
                                }
                                .padding(.leading, 24)
                                
                                VStack(spacing: 0) {
                                    NavigationLink(destination: SleepDetailHistoryView(sleep: journal.sleep)) {
                                        HStack {
                                            VStack(spacing: 0) {
                                                HStack {
                                                    Text("In Bed")
                                                        .foregroundStyle(.gray)
                                                        .font(.footnote)
                                                    Spacer()
                                                }
                                                HStack {
                                                    Text(parseSleepDuration(sleep: journal.sleep))
                                                    Spacer()
                                                }
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.black)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .padding(.trailing)
                                        }
                                        .background(Color(UIColor.systemBackground))
                                    }

                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                                
                            }
                        }
                    }
                    
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.background)
        }
        .onAppear {
//             generateDummy()
        }
        .navigationTitle("Semua Data Tercatat")
        .toolbar {
            EditButton()
        }
    }
    
    private func parseSleepDuration(sleep: Sleep) -> String {
        let hour: Int = sleep.duration / 3600
        let minut: Int = (sleep.duration % 3600) / 60
        
        return "\(hour)hrs \(minut)min"
    }
    
    private func deleteFood(food: Food) {
        for journal in journals {
            if let index = journal.foods.firstIndex(of: food) {
                journal.foods.remove(at: index)
            }
        }
        context.delete(food)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
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
        
        // Example start and end times
        let todayStart = calendar.date(byAdding: .hour, value: -8, to: today)!
        let todayEnd = today
        let yesterdayStart = calendar.date(byAdding: .hour, value: -8, to: yesterday)!
        let yesterdayEnd = yesterday
        let dayBeforeYesterdayStart = calendar.date(byAdding: .hour, value: -8, to: dayBeforeYesterday)!
        let dayBeforeYesterdayEnd = dayBeforeYesterday

        let todaySleep = Sleep(timestamp: today, duration: 8*3600, start: todayStart, end: todayEnd)
        let yesterdaySleep = Sleep(timestamp: yesterday, duration: 6*3600, start: yesterdayStart, end: yesterdayEnd)
        let dayBeforeYesterdaySleep = Sleep(timestamp: dayBeforeYesterday, duration: 5*3600, start: dayBeforeYesterdayStart, end: dayBeforeYesterdayEnd)
        
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
    HistoryView()
}
