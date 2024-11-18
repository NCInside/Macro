//
//  FoodInformationCard.swift
//  Macro
//
//  Created by Vebrillia Santoso on 28/10/24.
//
import SwiftUI

struct FoodInformationCard: View {
    
    let processedOptions = ["Rebus", "Goreng", "Bakar", "Tumis", "Sangrai", "Kukus", "Fresh"]
    @Binding var selectedProcessedOption: String
    let fatOptions = ["Jenuh", "Baik"]
    @Binding var selectedFatOption: String
    let milkOptions = ["Tidak Ada", "Ada"]
    @Binding var selectedMilkOption: String
    let glycemicOptions = ["Rendah", "Sedang", "Tinggi"]
    @Binding var selectedGlycemicOption: String
    
    
    var body: some View {
        VStack{
            HStack {
                Text("Informasi Makanan")
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Spacer()
            }
        
            
            VStack(spacing: 0) {
                HStack {
                    Text("Jenis Olahan")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.systemBlack)
                    
                    Picker("", selection: $selectedProcessedOption) {
                        ForEach(processedOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                    
                }
                .background(Color.systemWhite)
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Jenis Lemak")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.systemBlack)
                    
                    Picker("", selection: $selectedFatOption) {
                        ForEach(fatOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                }
                .background(Color.systemWhite)
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Kandungan Susu")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.systemBlack)
                    Picker("", selection: $selectedMilkOption) {
                        ForEach(milkOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                }
                .background(Color.systemWhite)
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Indeks Glikemik")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.systemBlack)
                    Picker("", selection: $selectedGlycemicOption) {
                        ForEach(glycemicOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                }
                .background(Color.systemWhite)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Text("*Ubah informasi makanan jika diperlukan")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.top, 4)
            
        }
    }
}

//#Preview {
//    FoodInformationCard()
//}
