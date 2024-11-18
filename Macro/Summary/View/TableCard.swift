//
//  TableCard.swift
//  Macro
//
//  Created by Vebrillia Santoso on 30/10/24.
//

import SwiftUI

struct TableRow: Identifiable {
    let id = UUID()
    let date: String
    let value: String
}

struct TableCard: View {
    var title: String
    var column2Header: String
    var rows: [TableRow]

    @State var chosenDate = Calendar.current.component(.day, from: Date())
    
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
            
            if rows.isEmpty {
                Text("Tidak ada Data")
                    .bold()
                    .font(.headline)
            }
            else {
                HStack {
                    Text("Tanggal")
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text(column2Header)
                            .fontWeight(.bold)
                       
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                
                
                ForEach(rows) { row in
                    HStack {
                        Text(row.date)
                            .frame(width: 120, alignment: .leading)
                        
                        Text(row.value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                    .background(Color.white)
                    .border(Color.gray.opacity(0.3), width: 0.5)
                }
            }
        }
        .cornerRadius(8)
        .shadow(radius: 0.08)
        
        
        
    }
    
    
}

#Preview {
    TableCard(
        title: "Riwayat Data Produk Susu",
        column2Header: "Jumlah Porsi",
        rows: [
            TableRow(date: "01/10/2024", value: "1 porsi"),
            TableRow(date: "02/10/2024", value: "2 porsi"),
            TableRow(date: "03/10/2024", value: "2 porsi")
        ]
        )
    
}
