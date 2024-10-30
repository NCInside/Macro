import SwiftUI

struct WeightOnBoardingView: View {
    @State private var inputWeight: String = ""
    @FocusState private var isInputActive: Bool
    @State private var weightOption = "kg"
    @Binding var hasCompletedOnboarding: Bool
    var weight = ["lb", "kg"]
    @ObservedObject var viewModel = OnBoardingViewModel()
    @State private var navigateToNext = false
    var navigationStates: [String: Bool]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Berapa beratmu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                VStack {
                    TextField("", text: $inputWeight)
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
                
                Picker("Weight", selection: $weightOption) {
                    ForEach(weight, id: \.self) {
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
                    if !inputWeight.isEmpty {
                        UserDefaults.standard.set(["weight": inputWeight, "metric": weightOption], forKey: "weight")
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
                .disabled(inputWeight.isEmpty)
                .opacity(inputWeight.isEmpty ? 0.5 : 1.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
            .onAppear(perform: {
                viewModel.subscribeToKeyboardEvents()
                
                // Automatically skip this view if WeightOnBoarding is not needed
                if navigationStates["WeightOnBoarding"] == false {
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
    
    // Helper function to update navigationStates to mark WeightOnBoarding as completed
    private func updatedNavigationStates() -> [String: Bool] {
        var updatedStates = navigationStates
        updatedStates["WeightOnBoarding"] = false // Mark WeightOnBoarding as completed
        return updatedStates
    }
    
    // Determine the next view based on updated navigationStates
    @ViewBuilder
    private func nextView(updatedNavigationStates: [String: Bool]) -> some View {
        if updatedNavigationStates["GenderOnBoarding"] == true {
            GenderOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else {
            ActivityOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        }
    }
}
