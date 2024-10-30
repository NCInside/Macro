import SwiftUI

struct HealthOnBoardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var manager: HealthManager
    
    @State private var navigateToAgeOnBoarding = false
    @State private var navigateToHeightOnBoarding = false
    @State private var navigateToWeightOnBoarding = false
    @State private var navigateToGenderOnBoarding = false
    @State private var navigateToActivityOnBoarding = false
    @State private var showAlert = false
    @State private var navigationStates: [String: Bool] = [:] // Store navigation states

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer()
                
                Image("Logo")
                    .padding(.horizontal)
                
                Text("Izin Akses Apple Health")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                Text("Pelacakan tidur dan pengukuran tubuh memerlukan akses ke informasi Kesehatan yang disimpan di Apple Health.")
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Text("Penting!")
                    .foregroundColor(.accentColor)
                    .padding(.top)
                    .padding(.horizontal)
                
                Text("Harap aktifkan semua kategori dalam dialog yang akan muncul. Tanpa akses penuh, Zora tidak akan dapat memberikan analisis dan wawasan yang lengkap.")
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    manager.requestAuthorization { success, returnedNavigationStates in
                        // Update navigation states and showAlert if necessary
                        navigationStates = returnedNavigationStates
                        showAlert = navigationStates["showAlert"] ?? false
                        
                        // Trigger navigation only if showAlert is false
                        if !showAlert {
                            navigateToNextOnboarding()
                        }
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: 353, height: 50)
                            .background(.white)
                            .cornerRadius(12)
                        Text("Lanjutkan")
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                // Navigation links based on states, passing navigationStates to the next views
                NavigationLink(destination: AgeOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: navigationStates), isActive: $navigateToAgeOnBoarding) { EmptyView() }
                NavigationLink(destination: HeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: navigationStates), isActive: $navigateToHeightOnBoarding) { EmptyView() }
                NavigationLink(destination: WeightOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: navigationStates), isActive: $navigateToWeightOnBoarding) { EmptyView() }
                NavigationLink(destination: GenderOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: navigationStates), isActive: $navigateToGenderOnBoarding) { EmptyView() }
                NavigationLink(destination: ActivityOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding , navigationStates: navigationStates), isActive: $navigateToActivityOnBoarding) { EmptyView() }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.main)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Tidak ada data tidur"),
                    message: Text("Data tidur selama 7 hari terakhir tidak ditemukan. Anda dapat mengunjungi halaman bantuan Apple untuk mempelajari cara mengaktifkan pelacakan tidur."),
                    primaryButton: .default(Text("Yes"), action: {
                        if let url = URL(string: "https://support.apple.com/en-us/108906") {
                            UIApplication.shared.open(url)
                        }
                        navigationStates["showAlert"] = false // Reset alert state
                        navigateToNextOnboarding()
                    }),
                    secondaryButton: .cancel(Text("Skip"), action: {
                        navigationStates["showAlert"] = false // Reset alert state
                        navigateToNextOnboarding()
                    })
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Function to navigate to the next onboarding view based on navigationStates
    private func navigateToNextOnboarding() {
        if navigationStates["AgeOnBoarding"] == true {
            navigateToAgeOnBoarding = true
        } else if navigationStates["HeightOnBoarding"] == true {
            navigateToHeightOnBoarding = true
        } else if navigationStates["WeightOnBoarding"] == true {
            navigateToWeightOnBoarding = true
        } else if navigationStates["GenderOnBoarding"] == true {
            navigateToGenderOnBoarding = true
        } else {
            navigateToActivityOnBoarding = true // Default to ActivityOnBoarding if all other steps are completed
        }
    }
}
