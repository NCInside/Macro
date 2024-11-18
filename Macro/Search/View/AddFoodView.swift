//
//  AddFoodView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 28/10/24.
//

import SwiftUI

struct AddFoodView: View {
    let unitOptions = ["Gram (gr)", "Mililiter (m/l)"]
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = SearchViewModel()
    @State private var inputName: String = ""
    @State private var inputPortion: String = ""
    @State private var selectedUnitOption = "Gram (gr)"
    @State var selectedProcessedOption = "Goreng"
    @State var selectedFatOption = "Jenuh"
    @State var selectedMilkOption = "Tidak Ada"
    @State var selectedGlycemicOption = "Rendah"
    @Binding var showingAlert: Bool
    @FocusState private var isTextFieldFocused: Bool
    
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
                    .foregroundColor(Color.systemBlack)
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
                        .foregroundStyle(Color.systemBlack)
                    TextField("Makanan/Minuman",  text: $inputName)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 16)
                        .focused($isTextFieldFocused)
                    
                }
                .background(Color(UIColor.systemBackground))
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Besar Porsi")
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: 140, alignment: .leading)
                        .foregroundStyle(Color.systemBlack)
                    TextField("Masukan porsi normal", text: $inputPortion)
                        .focused($isTextFieldFocused)
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
                        .foregroundStyle(Color.systemBlack)
                    
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
            
            
            FoodInformationCard(selectedProcessedOption: $selectedProcessedOption, selectedFatOption: $selectedFatOption, selectedMilkOption: $selectedMilkOption, selectedGlycemicOption: $selectedGlycemicOption)
            Spacer()
            
            Button(action: {
                processSave()
                dismiss()
            }) {
                Text("Simpan ke Menu")
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
        .onTapGesture {
                            isTextFieldFocused = false
                        }
        
    }
    
    private func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    
    func processSave() {
        
        if inputName.isEmpty || inputPortion.isEmpty {
            return
        }
        if let portion = Int(inputPortion), portion > 0 {
            let cook = [selectedProcessedOption]
            var gi: Int
            switch selectedGlycemicOption {
            case "Rendah":
                gi = 50
            case "Sedang":
                gi = 60
            case "Tinggi":
                gi = 70
            default:
                gi = 0
            }
            let dairy = selectedMilkOption == "Ada" ? 1 : 0
            let fat = selectedFatOption == "Jenuh" ? 6 : 0
            showingAlert.toggle()
            viewModel.addFoodName(name: inputName, cookingTechnique: cook, glycemicIndex: gi, dairies: dairy, saturatedFat: Double(fat), gramPortion: portion)
        }
        
    }
}

//#Preview {
//    AddFoodView()
//}
