//
//  OnBoardingAgeView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI

struct AgeOnBoardingView: View {
    @State private var inputAge: String = ""
    @FocusState private var isInputActive: Bool
    @State private var navigateToHeightOnBoarding = false
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        NavigationView{
        VStack{
            Text("Berapa usiamu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.systemWhite)
                .bold()
            
            VStack {
                TextField("", text: $inputAge)
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
            
            NavigationLink(destination: HeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigateToHeightOnBoarding){
                Button(action: {
                    UserDefaults.standard.set(inputAge, forKey: "age")
                    navigateToHeightOnBoarding = true
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AgeOnBoardingView()
//    }
//}

