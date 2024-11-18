//
//  DetailView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 12/11/24.
//

import SwiftUI

struct InfoView : View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "info.circle")
                Text("Detail Makanan")
                    .padding(.leading, -4)
                
                Spacer()
                
                HStack{
                    Image(systemName: "xmark")
                        .foregroundColor(.accent)
                }
                .onTapGesture {
                    dismiss()
                }
                
            }
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.top, 20)
            
            
            ScrollView{
                VStack(alignment: .leading){
                    HStack {
                        Text("Apa fungsi fitur ini?")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    
                    Text("Fitur ini membantu Anda mengidentifikasi dan mencatat jenis-jenis makanan yang Anda konsumsi berdasarkan komposisi kandungan utama seperti lemak jenuh, produk susu, dan indeks glikemik. Dengan memahami kategori ini, Anda bisa mendapatkan panduan lebih baik untuk menjaga pola makan yang mendukung kesehatan kulit dan tubuh.")
                        .font(.body)
                        .foregroundColor(Color.systemBlack.opacity(0.6))
                        .padding(.top, 1)
                    
                    HStack {
                        Text("Data apa yang kamu dapatkan?")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding(.top)
                    
                    VStack {
                        HStack {
                            Text("Makanan Berlemak")
                                .foregroundColor(Color.systemBlack)
                                .bold()
                            
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        
                        Text("Makanan tinggi lemak adalah makanan yang mengandung lebih dari 5 gram lemak jenuh per porsi. Lemak jenuh berlebih dapat mempengaruhi kondisi kulit, seperti meningkatkan risiko peradangan yang terkait dengan jerawat.")
                            .foregroundColor(Color.systemBlack.opacity(0.6))
                    }
                    .padding()
                    .frame(maxWidth: 370, maxHeight: 200)
                    .background(Color.systemWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.systemBlack.opacity(0.08), radius: 3, x: 2, y: 2)
                    
                    VStack {
                        HStack {
                            Text("Produk Susu")
                                .foregroundColor(Color.systemBlack)
                                .bold()
                            
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        
                        Text("Produk yang mengandung susu atau hasil olahan susu seperti keju, yogurt, mentega, dan krim. Batasi konsumsi produk susu utuh dan pertimbangkan alternatif rendah lemak atau non-dairy untuk menjaga kesehatan kulit dan tubuh Anda.")
                            .foregroundColor(Color.systemBlack.opacity(0.6))
                    }
                    .padding()
                    .frame(maxWidth: 370, maxHeight: 200)
                    .background(Color.systemWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.systemBlack.opacity(0.08), radius: 3, x: 2, y: 2)
                    .padding(.top, 6)
                    
                    VStack {
                        HStack {
                            Text("Indeks Glikemik (IG)")
                                .foregroundColor(Color.systemBlack)
                                .bold()
                            
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Indeks Glikemik (IG) mengukur seberapa cepat makanan yang mengandung karbohidrat meningkatkan kadar gula darah. Kami mengkategorikan makanan ini menjadi tiga kelompok:")
                               Text("• IG Rendah: (IG < 55)")
                                   .bold()
                                   + Text(" Meningkatkan gula darah secara perlahan.")
                               
                               Text("• IG Sedang: (IG 56–69)")
                                   .bold()
                                   + Text(" Meningkatkan gula darah dengan kecepatan sedang.")
                               
                               Text("• IG Tinggi: (IG > 70)")
                                   .bold()
                                   + Text(" Meningkatkan gula darah dengan cepat, yang dapat memicu produksi minyak berlebih pada kulit dan dapat menyebabkan jerawat.")
                           }
                        .foregroundColor(Color.systemBlack.opacity(0.6))
                    }
                    .padding()
                    .frame(maxWidth: 370, maxHeight: .infinity)
                    .background(Color.systemWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.systemBlack.opacity(0.08), radius: 3, x: 2, y: 2)
                    .padding(.top, 6)
                }
                .padding()
            }
        }
        .background(Color.background)
    }
}

#Preview {
    InfoView()
}
