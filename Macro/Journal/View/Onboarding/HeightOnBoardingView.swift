//
//  HeightOnBoardingView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 16/10/24.
//

import SwiftUI

struct HeightOnBoardingView: View {
    @State private var inputHeight: String = ""
    @FocusState private var isInputActive: Bool
    @State private var heightOption = "cm"
    @State private var navigationToWeightOnBoarding = false
    @Binding var hasCompletedOnboarding: Bool
    var height = ["ft", "cm"]
    
    var body: some View {
        NavigationView{
        VStack{
            Text("Berapa tinggimu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.systemWhite)
                .bold()
            
            VStack {
                TextField("", text: $inputHeight)
                    .keyboardType(.numberPad)
                    .focused($isInputActive)
                    .font(.largeTitle)
                    .foregroundColor(.systemWhite)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.top, 120)
                    .bold()
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isInputActive = false
                            }
                        }
                    }
            }
            
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
                .padding(.horizontal, 60)
            
            Picker("Height", selection: $heightOption) {
                ForEach(height, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .padding(.horizontal, 42)
            .colorMultiply(.accentColor)
            
            NavigationLink(destination: WeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigationToWeightOnBoarding){
                Button(action: {
                    UserDefaults.standard.set(inputHeight, forKey: "height")
                    navigationToWeightOnBoarding = true
                }) {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: 353, height: 50)
                            .background(.white)
                            .cornerRadius(12)
                        Text("Selanjutnya")
                            .foregroundColor(.white)
                        
                    }
                    .padding()
                    .padding(.top, 80)
                }
            }
            
            
            
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
        .background(Color.main)
    }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    HeightOnBoardingView()
//}
