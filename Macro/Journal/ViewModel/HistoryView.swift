//
//  HistoryView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI

struct HistoryView: View {
    @State private var historyOption = "Diet"
    var colors = ["Diet", "Sleep"]
    
    var body: some View {
        NavigationView{
            VStack {
                Picker("History", selection: $historyOption) {
                    ForEach(colors, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                
                HStack {
                    Text("Tanggal")
                        .font(.callout)
                    Spacer()
                    
                }
                .padding()
                
                List{
                    NavigationLink(destination: DetailHistoryView(title: "Detail A")) {
                        Text("A")
                    }
                    NavigationLink(destination: DetailHistoryView(title: "Detail B")) {
                        Text("B")
                    }
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -40)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.background)
        }
        .navigationTitle("Semua Data Tercatat")
        .toolbar { EditButton() }
    }
}

#Preview {
    HistoryView()
}
