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
    
    @ObservedObject var viewModel = OnBoardingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Berapa usiamu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
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
                
                Spacer()
                
                NavigationLink(destination: HeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigateToHeightOnBoarding) {
                    EmptyView()
                }

                Button(action: {
                    if !inputAge.isEmpty {
                        UserDefaults.standard.set(inputAge, forKey: "age")
                        navigateToHeightOnBoarding = true
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: 353, height: 50)
                            .background(.white)
                            .cornerRadius(12)
                        Text("Selanjutnya")
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    .offset(y: viewModel.keyboardHeight == 0 ? 0 : -viewModel.keyboardHeight / 14)
                    .animation(.easeOut(duration: 0.3), value: viewModel.keyboardHeight)
                }
                .disabled(inputAge.isEmpty)
                .opacity(inputAge.isEmpty ? 0.5 : 1.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
            .onAppear(perform: viewModel.subscribeToKeyboardEvents)
            .onDisappear(perform: viewModel.unsubscribeFromKeyboardEvents)
        }
        .navigationBarBackButtonHidden()
    }
}




//struct ContentView_Previews: PreviewProvider {
//    @State static var hasCompletedOnboarding = false
//    
//    static var previews: some View {
//        AgeOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
//    }
//}
