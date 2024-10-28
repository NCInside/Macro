//
//  AddFoodView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 28/10/24.
//

import SwiftUI

struct AddFoodView: View {
    let unitOptions = ["Porsi", "Gram (gr)", "Mililiter (m/l)"]
    @State private var selectedUnitOption = "Porsi"
    @Environment(\.dismiss) private var dismiss
    @State private var inputPortion: String = ""
    @State private var inputName: String = ""
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                HStack (spacing: 4) {
                    Image(systemName: "chevron.left")
                    
                    
                }.onTapGesture {
                    dismiss()
                    
                }
                Spacer()
                Text("Tambah Menu Baru")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                Spacer()
                
                
            }
            .padding(.bottom, 12)
            .foregroundColor(.accentColor)
            
            Text("Detail Makanan")
                .bold()
                .font(.callout)
                .padding(.horizontal, 4)
                .padding(.top, 10)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Nama Menu")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    TextField("Makanan/Minuman",  text: $inputName)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 16)
                    
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Banyak Porsi")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    TextField("Masukan porsi",  text: $inputPortion)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 16)
                    
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Satuan")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.black)
                    
                    Picker("", selection: $selectedUnitOption) {
                        ForEach(unitOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                            
                        }
                        
                    }
                    .accentColor(.gray)
                    
                }
                .background(Color(UIColor.systemBackground))
                
                
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 20)
            
            
            FoodInformationCard()
            Spacer()
            
            Button(action: {
                
            }) {
                Text("Simpan ke Jurnal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                
            }
            
        }
        .padding()
        .background(Color.background)
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        
    }
}

#Preview {
    AddFoodView()
}
