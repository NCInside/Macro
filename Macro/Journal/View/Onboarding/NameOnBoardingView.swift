import SwiftUI

struct NameOnBoardingView: View {
    @State private var inputName: String = ""
    @FocusState private var isInputActive: Bool
    @State private var navigateToNext = false
    @Binding var hasCompletedOnboarding: Bool
    
    var navigationStates: [String: Bool]
    @ObservedObject var viewModel = OnBoardingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Siapa namamu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                VStack {
                    TextField("Enter your name", text: $inputName)
                        .focused($isInputActive)
                        .font(.largeTitle)
                        .foregroundColor(.white)
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
                
                // Updated NavigationLink
                NavigationLink(destination: nextView(updatedNavigationStates: updatedNavigationStates()), isActive: $navigateToNext) {
                    EmptyView()
                }

                Button(action: {
                    if !inputName.isEmpty {
                        UserDefaults.standard.set(inputName, forKey: "name")
                        navigateToNextStep()
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
                .disabled(inputName.isEmpty)
                .opacity(inputName.isEmpty ? 0.5 : 1.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
            .onAppear {
                viewModel.subscribeToKeyboardEvents()
                
                // Auto-navigate if NameOnBoarding is already completed
                if navigationStates["NameOnBoarding"] == false {
                    navigateToNextStep()
                }
            }
            .onDisappear(perform: viewModel.unsubscribeFromKeyboardEvents)
        }
        .navigationBarBackButtonHidden()
    }
    
    private func navigateToNextStep() {
        navigateToNext = true
    }
    
    private func updatedNavigationStates() -> [String: Bool] {
        var updatedStates = navigationStates
        updatedStates["NameOnBoarding"] = false
        updatedStates["AgeOnBoarding"] = updatedStates["AgeOnBoarding"] ?? true // Ensure AgeOnBoarding is next
        return updatedStates
    }
    
    @ViewBuilder
    private func nextView(updatedNavigationStates: [String: Bool]) -> some View {
        if updatedNavigationStates["AgeOnBoarding"] == true {
            AgeOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else if updatedNavigationStates["HeightOnBoarding"] == true {
            HeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else if updatedNavigationStates["WeightOnBoarding"] == true {
            WeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else if updatedNavigationStates["GenderOnBoarding"] == true {
            GenderOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else {
            ActivityOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        }
    }
}
