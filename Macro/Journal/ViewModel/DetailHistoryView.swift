//
//  DetailHistoryView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI

struct DetailHistoryView: View {
    var title: String
        
        var body: some View {
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .padding()
                
                
                Text("Detail dari \(title)")
                    .font(.body)
                    .padding()
                
                Spacer()
            }
            .navigationTitle(title)
        }
}

//#Preview {
//    DetailHistoryView()
//}
