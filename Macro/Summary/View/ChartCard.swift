//
//  ChartCard.swift
//  Macro
//
//  Created by Vebrillia Santoso on 17/10/24.
//

import SwiftUI
import Charts

struct ChartCard: View {
    @ObservedObject var viewModel = ChartCardViewModel()
    
    var body: some View {
        VStack {
            Picker("duration", selection: $viewModel.selectedTab) {
                ForEach(viewModel.tabs, id: \.self) { tab in
                    Text(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Chart {
                ForEach(viewModel.chartData) { item in
                    BarMark(x: .value("date", item.dateLabel), y: .value("value", item.value))
                        .foregroundStyle(Color.mint)
                }
            }
            .frame(width: 300, height: 200) 
            .padding()
        }
    }
}

#Preview {
    ChartCard()
}

