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
                        .foregroundStyle(.black)
                    
                    Picker("", selection: $selectedProcessedOption) {
                        ForEach(processedOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                    
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Jenis Lemak")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    
                    Picker("", selection: $selectedFatOption) {
                        ForEach(fatOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Kandungan Susu")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Picker("", selection: $selectedMilkOption) {
                        ForEach(milkOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                HStack {
                    Text("Indeks Glisemik")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    Picker("", selection: $selectedGlycemicOption) {
                        ForEach(glycemicOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                }
                .background(Color(UIColor.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
        }
    }
}

//#Preview {
//    FoodInformationCard()
//}

