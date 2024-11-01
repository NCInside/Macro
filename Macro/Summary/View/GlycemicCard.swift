//
//  GlycemicCard.swift
//  Macro
//
//  Created by Vebrillia Santoso on 30/10/24.
//

import SwiftUI

struct GlycemicIndexRow: Identifiable {
    let id = UUID()
    let date: String
    let low: String
    let medium: String
    let high: String
}

struct GlycemicCard: View {
    var title: String
    var rows: [GlycemicIndexRow]
    
    var body: some View {
        VStack {
            
            VStack {
                Text(title)
                    .padding(6)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.main)
            )
            .padding(.bottom, 20)
            .padding(.top, 16)
            
           
            HStack {
                Text("Tanggal")
                    .fontWeight(.bold)
                    .frame(width: 120, alignment: .leading)
                
                VStack(alignment: .leading) {
                    HStack{
                        Spacer()
                        Text("Jumlah Porsi")
                            .fontWeight(.bold)
                            .padding(.bottom, 2)
                        Spacer()
                    }
                    HStack {
                        Text("Rendah")
                            .frame(maxWidth: .infinity)
                        Text("Sedang")
                            .frame(maxWidth: .infinity)
                        Text("Tinggi")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            
            // Data rows
            ForEach(rows) { row in
                HStack {
                    Text(row.date)
                        .frame(width: 120, alignment: .leading)
                    
                    HStack {
                        Text(row.low)
                            .frame(maxWidth: .infinity)
                        Text(row.medium)
                            .frame(maxWidth: .infinity)
                        Text(row.high)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(10)
                .background(Color.white)
                .border(Color.gray.opacity(0.3), width: 0.5)
            }
        }
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

#Preview {
    GlycemicCard(
        title: "Riwayat Data Indeks Glikemik",
        rows: [
            GlycemicIndexRow(date: "01/10/2024", low: "1", medium: "1", high: "3"),
            GlycemicIndexRow(date: "02/10/2024", low: "1", medium: "1", high: "3"),
            GlycemicIndexRow(date: "03/10/2024", low: "1", medium: "1", high: "3"),
            GlycemicIndexRow(date: "04/10/2024", low: "1", medium: "1", high: "3"),
            GlycemicIndexRow(date: "05/10/2024", low: "1", medium: "1", high: "3"),
            GlycemicIndexRow(date: "06/10/2024", low: "1", medium: "1", high: "3"),
        ]
    )
}
