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
    @ObservedObject var viewModel = OnBoardingViewModel()
    
    var body: some View {
        NavigationView{
        VStack{
            Text("Berapa tinggimu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white)
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
            
            Spacer()
            
            NavigationLink(destination: WeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigationToWeightOnBoarding){
                EmptyView()
            }
            Button(action: {
                if !inputHeight.isEmpty {
                UserDefaults.standard.set(inputHeight, forKey: "height")
                navigationToWeightOnBoarding = true
            }
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
                    .padding(.bottom, 20)
                    .offset(y: viewModel.keyboardHeight > 0 ? -viewModel.keyboardHeight / 2 : 0)
                    .animation(.easeOut(duration: 0.3), value: viewModel.keyboardHeight)
                }
                .disabled(inputHeight.isEmpty)
                .opacity(inputHeight.isEmpty ? 0.5 : 1.0)
            
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
        .background(Color.main)
        .onAppear(perform: viewModel.subscribeToKeyboardEvents)
        .onDisappear(perform: viewModel.unsubscribeFromKeyboardEvents)
    }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    HeightOnBoardingView()
//}
