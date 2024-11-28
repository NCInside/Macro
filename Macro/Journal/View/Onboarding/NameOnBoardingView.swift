import SwiftUI

struct NameOnBoardingView: View {
    @State private var inputName: String = ""
    @FocusState private var isInputActive: Bool
    @State private var navigateToNext = false
    @Binding var hasCompletedOnboarding: Bool
    
    var navigationStates: [String: Bool]
    @ObservedObject var viewModel = OnBoardingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Siapa namamu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                VStack {
                    TextField("Tuliskan Namamu", text: $inputName)
                        .focused($isInputActive)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.top, 100)
                        .bold()
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Selesai") {
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
                
                // Conditional NavigationLink based on hasCompletedOnboarding state
                NavigationLink(destination: JournalView(), isActive: $hasCompletedOnboarding) {
                    EmptyView()
                }
                
                NavigationLink(destination: AgeOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: navigationStates), isActive: $navigateToNext) {
                    EmptyView()
                }

                Button(action: {
                    if !inputName.isEmpty {
                        // Save the name to UserDefaults
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
                    .padding(.bottom, 10)
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
                
                if navigationStates["NameOnBoarding"] == false {
                    navigateToNextStep()
                }
            }
            .onDisappear(perform: viewModel.unsubscribeFromKeyboardEvents)
        }
        .navigationBarBackButtonHidden()
    }
    
    private func navigateToNextStep() {
        // Check if dateOfBirth exists in UserDefaults
        if UserDefaults.standard.string(forKey: "dateOfBirth") == nil {
            navigateToNext = true // Navigate to AgeOnBoardingView
        } else {
            hasCompletedOnboarding = true // Complete onboarding and go to JournalView
        }
    }
}
