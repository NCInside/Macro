import SwiftUI

struct ActivityOnBoardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var navigateToJournal = false
    var navigationStates: [String: Bool]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Seberapa berat aktivitasmu?")
                    .padding(.top, 80)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                // NavigationLink to JournalView triggered by hasCompletedOnboarding
                NavigationLink(destination: JournalView(), isActive: $navigateToJournal) {
                    EmptyView()
                }
                
                Button(action: {
                    UserDefaults.standard.set(1.2, forKey: "activtyLevel")
                    completeOnboarding()
                }) {
                    activityOptionView(
                        title: "Tidak Terlalu Aktif",
                        description: "Sebagian besar waktu duduk\n(contoh: pekerja kantoran, customer service)"
                    )
                    .padding(.top, 140)
                }
                
                Button(action: {
                    UserDefaults.standard.set(1.375, forKey: "activtyLevel")
                    completeOnboarding()
                }) {
                    activityOptionView(
                        title: "Sedikit Aktif",
                        description: "Sebagian besar waktu duduk\n(contoh: pekerja kantoran, customer service)"
                    )
                    .padding(.top)
                }
                
                Button(action: {
                    UserDefaults.standard.set(1.55, forKey: "activtyLevel")
                    completeOnboarding()
                }) {
                    activityOptionView(
                        title: "Aktif",
                        description: "Sebagian waktu melakukan aktivitas fisik\n(contoh: pramusaji, pemandu wisata, kurir paket)"
                    )
                    .padding(.top)
                }
                
                Button(action: {
                    UserDefaults.standard.set(1.725, forKey: "activtyLevel")
                    completeOnboarding()
                }) {
                    activityOptionView(
                        title: "Sangat Aktif",
                        description: "Sebagian besar waktu melakukan aktivitas berat\n(contoh: penari, tukang)"
                    )
                    .padding(.top)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.main)
        }
        .navigationBarBackButtonHidden()
    }
    
    // Function to mark onboarding as completed and navigate to JournalView
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        navigateToJournal = true
    }
    
    // Reusable view for activity options
    private func activityOptionView(title: String, description: String) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.mainLight)
                .frame(width: 353, height: 80)
                .background(.white)
                .cornerRadius(12)
            
            VStack {
                Text(title)
                    .foregroundColor(.white)
                    .bold()
                
                Text(description)
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
        }
    }
}

//#Preview {
//    ActivityOnBoardingView()
//}
