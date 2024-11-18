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
    
    var date: Date
    
    @Binding var isDetailViewPresented: Bool
    
    var name: String
    var journals: [Journal]
    @State private var inputPortion: String = "1"
    
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
                    .foregroundColor(Color.systemBlack)
                    .fontWeight(.semibold)
                
                Spacer()
                
                
            }
            .padding(.bottom, 12)
            .foregroundColor(.accentColor)
            
            Text(name)
                .bold()
                .font(.title2)
                .padding(.horizontal, 4)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Banyak Porsi")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.systemBlack)
                    TextField("Masukan porsi",  text: $inputPortion)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 16)
                    
                }
                .background(Color.systemWhite)
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Satuan")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.systemBlack)
                    
                    Picker("", selection: $selectedUnitOption) {
                                            ForEach(unitOptions, id: \.self) { option in
                                                Text(option)
                                                    .tag(option)
                                                   
                                            }
                                            
                                        }
                    .accentColor(.gray)
                    
                }
                .background(Color.systemWhite)
                
                
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 20)
            
            
            FoodInformationCard(selectedProcessedOption: $viewModel.selectedProcessedOption, selectedFatOption: $viewModel.selectedFatOption, selectedMilkOption: $viewModel.selectedMilkOption, selectedGlycemicOption: $viewModel.selectedGlycemicOption)
            Spacer()
            
            Button(action: {
                if let portion = Int(inputPortion), portion > 0 {
                    viewModel.addDiet(context: context, name: name, entries: journals, portion: portion, unit: selectedUnitOption, date: date)
                    isDetailViewPresented = false
                }
            }) {
                Text("Simpan ke Jurnal")
                    .font(.headline)
                    .foregroundColor(Color.systemWhite)
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

//#Preview {
//    DetailSearchView(name: "Abon", journals: [])
//}
