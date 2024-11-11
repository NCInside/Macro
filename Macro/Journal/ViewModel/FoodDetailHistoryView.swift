//
//  DetailHistoryView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI

struct FoodDetailHistoryView: View {
    
    var food: Food
        
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Jenis Lemak")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text(food.fat >= 5 ? "Jenuh" : "Tidak Jenuh")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Dairies")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text(food.dairy ? "Ada" : "Tidak Ada")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Indeks Glikemik")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Text(giToString(gi: food.glycemicIndex))
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.gray)
                }
                .background(Color(UIColor.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.background)
        .navigationTitle(food.name)
    }
    
    private func giToString(gi: glycemicIndex) -> String {
        switch gi {
        case .low:
            return "Rendah"
        case .medium:
            return "Sedang"
        case .high:
            return "Tinggi"
        }
    }
}

//#Preview {
//    DetailHistoryView()
//}
