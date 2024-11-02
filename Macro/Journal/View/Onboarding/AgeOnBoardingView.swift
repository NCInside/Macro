import SwiftUI

struct AgeOnBoardingView: View {
    @State private var inputAge: String = ""
    @FocusState private var isInputActive: Bool
    @State private var navigateToNext = false // Control navigation to the next view
    @Binding var hasCompletedOnboarding: Bool
    
    var navigationStates: [String: Bool] // Receive navigation states as a parameter
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
                
                // NavigationLink that dynamically determines the next destination
                NavigationLink(destination: nextView(updatedNavigationStates: updatedNavigationStates()), isActive: $navigateToNext) {
                    EmptyView()
                }

                Button(action: {
                    if !inputAge.isEmpty {
                        UserDefaults.standard.set(inputAge, forKey: "age")
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
                .disabled(inputAge.isEmpty)
                .opacity(inputAge.isEmpty ? 0.5 : 1.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
            .onAppear(perform: {
                viewModel.subscribeToKeyboardEvents()
                
                // Auto-navigate if AgeOnBoarding is not needed
                if navigationStates["AgeOnBoarding"] == false {
                    navigateToNextStep()
                }
            })
            .onDisappear(perform: viewModel.unsubscribeFromKeyboardEvents)
        }
        .navigationBarBackButtonHidden()
    }
    
    // Function to handle navigation to the next onboarding step
    private func navigateToNextStep() {
        navigateToNext = true
    }
    
    // Helper function to update navigationStates to mark AgeOnBoarding as completed
    private func updatedNavigationStates() -> [String: Bool] {
        var updatedStates = navigationStates
        updatedStates["AgeOnBoarding"] = false // Mark AgeOnBoarding as completed
        return updatedStates
    }
    
    // Determine the next view based on the updated navigationStates
    @ViewBuilder
    private func nextView(updatedNavigationStates: [String: Bool]) -> some View {
        if updatedNavigationStates["HeightOnBoarding"] == true {
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
