import SwiftUI

struct HeightOnBoardingView: View {
    @State private var inputHeight: String = ""
    @FocusState private var isInputActive: Bool
    @State private var heightOption = "cm"
    @Binding var hasCompletedOnboarding: Bool
    var height = ["ft", "cm"]
    @ObservedObject var viewModel = OnBoardingViewModel()
    @State private var navigateToNext = false
    var navigationStates: [String: Bool]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Berapa tinggimu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                VStack {
                    TextField("", text: $inputHeight)
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
                
                // Dynamic NavigationLink
                NavigationLink(destination: nextView(updatedNavigationStates: updatedNavigationStates()), isActive: $navigateToNext) {
                    EmptyView()
                }
                
                Button(action: {
                    if !inputHeight.isEmpty {
                        UserDefaults.standard.set(inputHeight, forKey: "height")
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
                    .offset(y: viewModel.keyboardHeight > 0 ? -viewModel.keyboardHeight / 2 : 0)
                    .animation(.easeOut(duration: 0.3), value: viewModel.keyboardHeight)
                }
                .disabled(inputHeight.isEmpty)
                .opacity(inputHeight.isEmpty ? 0.5 : 1.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
            .onAppear(perform: {
                viewModel.subscribeToKeyboardEvents()
                
                // Automatically skip this view if HeightOnBoarding is not needed
                if navigationStates["HeightOnBoarding"] == false {
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
    
    // Helper function to update navigationStates to mark HeightOnBoarding as completed
    private func updatedNavigationStates() -> [String: Bool] {
        var updatedStates = navigationStates
        updatedStates["HeightOnBoarding"] = false // Mark HeightOnBoarding as completed
        return updatedStates
    }
    
    // Determine the next view based on updated navigationStates
    @ViewBuilder
    private func nextView(updatedNavigationStates: [String: Bool]) -> some View {
        if updatedNavigationStates["WeightOnBoarding"] == true {
            WeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else if updatedNavigationStates["GenderOnBoarding"] == true {
            GenderOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else {
            ActivityOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        }
    }
}
