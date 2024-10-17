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
    
    @StateObject private var viewModel = SummaryViewModel()
    @Query var journals: [Journal]
        
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
            case .protein:
                HStack {
                    Text("Protein")
                        .bold()
                        .font(.largeTitle)
                        .padding(.leading, 8)
                    Spacer()
                }
            case .fat:
                HStack {
                    Text("Lemak")
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
                Chart {
                    ForEach(viewModel.points) { item in
                        BarMark(x: .value("date", item.date), y: .value("value", item.value))
                            .foregroundStyle(Color.mint)
                    }
                }
                .frame(width: 350, height: 250)
                Spacer()
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.getPoints(journals: journals, scenario: scenario, chosenMonth: chosenMonth)
        }
    }
}

//#Preview {
//    DetailSummaryView(scenario: .sleep)
//}
