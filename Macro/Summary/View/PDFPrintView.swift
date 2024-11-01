//
//  PDFPrintView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 25/10/24.
//


import SwiftUI
import Charts
import SwiftData

struct PDFPrintView: View {
    @State var chosenMonth = Calendar.current.component(.month, from: Date())
    @State var protein: Double = 0
    @State var fat: Double = 0
    @State var chosenYear = Calendar.current.component(.year, from: Date())
    @StateObject private var viewModel = SummaryViewModel()
   
    @Query var journals: [Journal]
    @Environment(\.modelContext) var context
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    let age = UserDefaults.standard.string(forKey: "age") ?? "Unknown age"
    let gender = UserDefaults.standard.string(forKey: "gender") ?? "Unknown gender"
    let weight = UserDefaults.standard.string(forKey: "weight") ?? "Unknown weigth"
    let height = UserDefaults.standard.string(forKey: "height") ?? "Unknown heigth"
    
    
    var body: some View {
//        ScrollView{
            VStack (alignment: .leading) {
                VStack(alignment: .center) {
                    Image("ZoraHeader")
                        .resizable()
                        .frame(width: 280, height: 55)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.main)
                .padding(.horizontal, -20)
                .padding(.bottom, 10)
                
                Text("Nama")
                    .bold()
                    .font(.title2)
                    .padding(.bottom, 10)
                
                HStack{
                    VStack(alignment: .leading){
                        Text("Usia : \(UserDefaults.standard.string(forKey: "age") ?? "not set") " )
                        
                        Text("Jenis Kelamin : \(UserDefaults.standard.string(forKey: "gender") ?? "not set") " )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading){
                        Text("Berat Badan : \(UserDefaults.standard.string(forKey: "weight") ?? "not set")" )
                        
                        Text("Tinggi Badan : \(UserDefaults.standard.string(forKey: "height") ?? "not set")" )
                    }
                    .padding(.leading, 10)
                }
                .padding(.bottom, 10)
                
                Divider()
                    .frame(minHeight: 3)
                    .overlay(Color.gray.opacity(0.3))
                    .padding(.bottom, 10)
                
                Text("Periode")
                
                HStack {
                    Text("\(months[chosenMonth]) \(String(chosenYear))")
                        .bold()
                        .font(.title2)
                    Spacer()
                }
                .padding(.bottom, 10)
                
                VStack {
                    Text("Grafik Bulanan")
                        .padding(6)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.main)
                )
                .padding(.bottom, 16)
                
                
                Text("Tidur")
                    .fontWeight(.semibold)
                
                Text("Makanan Berlemak")
                    .fontWeight(.semibold)
                
                Text("Lemak Jenuh")
                    .fontWeight(.semibold)
                
                Text("Produk Susu")
                    .fontWeight(.semibold)
                
                Text("Indeks Glikemik")
                    .fontWeight(.semibold)
                
                
                TableCard(
                    title: "Riwayat Data Tidur",
                    column2Header: "Lama Tidur",
                    rows: [
                        
                    ])
                
                TableCard(
                    title: "Riwayat Data Makanan Berlemak",
                    column2Header: "Jumlah Porsi",
                    rows: [
                        
                    ],
                    note: "(>5gr lemak jenuh)")
                
                TableCard(
                    title: "Riwayat Data Lemak Jenuh",
                    column2Header: "Komposisi Lemak Jenuh",
                    rows: [
                        
                    ],
                    note: "(rekomendasi <17 gram)")
                
                TableCard(
                    title: "Riwayat Data Produk Susu",
                    column2Header: "Jumlah Porsi",
                    rows: [
                        
                    ],
                    note: "(rekomendasi 1 porsi)")
                
                GlycemicCard(
                    title: "Riwayat Data Indeks Glikemik",
                    rows: [
                        
                    ]
                )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
            .background(Color.background)
//        }
    }
}

#Preview {
    PDFPrintView()
}
