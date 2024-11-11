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
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh.MM"
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
                                
                                if !journal.foods.isEmpty {
                                    HStack {
                                        Text("\(journal.timestamp, formatter: dateFormatter)")
                                            .font(.callout)
                                        Spacer()
                                        
                                    }
                                    .padding(.leading, 24)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(journal.foods.sorted { $0.timestamp > $1.timestamp }, id: \.self) { food in
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

                                }
                                
                            } else {
                                
                                if journal.sleep.duration > 0 {
                                    HStack {
                                        Text("\(Calendar.current.date(byAdding: .day, value: -1, to: journal.timestamp) ?? Date(), formatter: dateFormatter) - \(journal.timestamp, formatter: dateFormatter)")
                                            .font(.callout)
                                        Spacer()
                                    }
                                    .padding(.leading, 24)
                                    
                                    VStack(spacing: 0) {
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
                                                    Text("\(timeFormatter.string(from: journal.sleep.start)) - \(timeFormatter.string(from: journal.sleep.end))")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.gray)
                                                }
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.black)
                                        }
                                        .background(Color(UIColor.systemBackground))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)

                                }
                                
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
}

#Preview {
    HistoryView()
}
