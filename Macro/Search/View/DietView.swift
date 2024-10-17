//
//  DietView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 08/10/24.
//

import SwiftUI
import SwiftData

struct DietView: View {
    
    @Query private var journals: [Journal]
    @ObservedObject private var viewModel = DietViewModel()
    @State private var isPresented = false
    let formatter1 = DateFormatter()
    
    init() {
        formatter1.dateStyle = .short
    }

    var body: some View {
        HStack {
            Button("Present!") {
                        isPresented.toggle()
                    }
            .fullScreenCover(isPresented: $isPresented, content: SearchView.init)
        }
        List {
            ForEach(journals) { journal in
                Text(formatter1.string(from: journal.timestamp))
                ForEach(journal.foods) { food in
                    Text(food.name)
                }
                
            }
        }
    }
    
}

#Preview {
    DietView()
}
