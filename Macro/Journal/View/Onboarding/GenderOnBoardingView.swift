import SwiftUI

struct GenderOnBoardingView: View {
    @State private var navigateToNext = false
    @Binding var hasCompletedOnboarding: Bool
    var navigationStates: [String: Bool]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Apa Jenis Kelaminmu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                // NavigationLink that dynamically determines the next destination
                NavigationLink(destination: nextView(updatedNavigationStates: updatedNavigationStates()), isActive: $navigateToNext) {
                    EmptyView()
                }
                
                Button(action: {
                    UserDefaults.standard.set(false, forKey: "gender") // Set gender as female
                    navigateToNextStep()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.mainLight)
                            .frame(width: 353, height: 60)
                            .background(.white)
                            .cornerRadius(12)
                        Text("♀ Perempuan")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .padding(.top, 140)
                }
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "gender") // Set gender as male
                    navigateToNextStep()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.mainLight)
                            .frame(width: 353, height: 60)
                            .background(.white)
                            .cornerRadius(12)
                        Text("⚦ Laki-Laki")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
        }
        .navigationBarBackButtonHidden()
    }
    
    // Function to handle navigation to the next onboarding step
    private func navigateToNextStep() {
        navigateToNext = true
    }
    
    // Helper function to update navigationStates to mark GenderOnBoarding as completed
    private func updatedNavigationStates() -> [String: Bool] {
        var updatedStates = navigationStates
        updatedStates["GenderOnBoarding"] = false // Mark GenderOnBoarding as completed
        return updatedStates
    }
    
    // Determine the next view based on updated navigationStates
    @ViewBuilder
    private func nextView(updatedNavigationStates: [String: Bool]) -> some View {
        if updatedNavigationStates["HeightOnBoarding"] == true {
            HeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else if updatedNavigationStates["WeightOnBoarding"] == true {
            WeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        } else {
            ActivityOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: updatedNavigationStates)
        }
    }
}
