//
//  DetailSearchView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 17/10/24.
//

import SwiftUI

struct DetailSearchView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = SearchViewModel()
    let unitOptions = ["Porsi", "Gram (gr)", "Mililiter (m/l)"]
    @State private var selectedUnitOption = "Porsi"
    
    var name: String
    var journals: [Journal]
    @State private var inputPortion: String = ""
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                HStack (spacing: 4) {
                    Image(systemName: "chevron.left")
                    
                    
                }.onTapGesture {
                    dismiss()
                    
                }
                Spacer()
                Text("Detail Makanan")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                Spacer()
                
                
            }
            .padding(.bottom, 12)
            .foregroundColor(.accentColor)
            
            Text(name)
                .bold()
                .font(.largeTitle)
                .padding(.horizontal, 4)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
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
                viewModel.addDiet(context: context, name: name, entries: journals)
                viewModel.isPresented.toggle()
                dismiss()
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
        .onAppear {
            viewModel.detailDiet(name: name)
        }
    }
    
    private func giToString(gi: glycemicIndex) -> String {
        switch gi {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
}

#Preview {
    DetailSearchView(name: "Abon", journals: [])
}
