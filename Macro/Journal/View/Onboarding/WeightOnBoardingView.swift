//
//  WeightOnBoardingView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 16/10/24.
//

import SwiftUI

struct WeightOnBoardingView: View {
    @State private var inputWeight: String = ""
    @FocusState private var isInputActive: Bool
    @State private var weightOption = "kg"
    @State private var navigateToGenderOnBoarding = false
    @Binding var hasCompletedOnboarding: Bool
    var weight = ["lb", "kg"]
    
    var body: some View {
        NavigationView{
        VStack{
            Text("Berapa beratmu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.systemWhite)
                .bold()
            
            VStack {
                TextField("", text: $inputWeight)
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
            
            Picker("Height", selection: $weightOption) {
                ForEach(weight, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .padding(.horizontal, 42)
            .colorMultiply(.accentColor)
            
            
            NavigationLink(destination: GenderOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigateToGenderOnBoarding){
                Button(action: {
                    UserDefaults.standard.set(["weight": inputWeight, "metric": weightOption], forKey: "weight")
                    navigateToGenderOnBoarding = true
                }) {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.mainLight)
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
//    WeightOnBoardingView()
//}
