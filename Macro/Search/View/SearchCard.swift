//
//  SearchCard.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 15/10/24.
//

import SwiftUI

struct SearchCard: View {
    
    let suggestion: String
    let onTap: () -> Void
    
    var body: some View {
        Text(suggestion)
            .font(.headline)
            .padding(
                EdgeInsets(
                    top: 25,
                    leading: 5,
                    bottom: 25,
                    trailing: 5
                )
            )
            
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 5)
                .background(.clear)
                .foregroundColor(.white)
                .padding(
                    EdgeInsets(
                        top: 2,
                        leading: 10,
                        bottom: 2,
                        trailing: 10
                    )
                )
        )
    }
}

//#Preview {
//    SearchView()
//}
