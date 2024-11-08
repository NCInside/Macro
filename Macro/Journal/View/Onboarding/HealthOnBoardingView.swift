import SwiftUI

struct HealthOnBoardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var manager: HealthManager
    @State private var navigateToNameOnBoarding = false
    @State private var showAlert = false
    @State private var navigationStates: [String: Bool] = [:]

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
                
                VStack {
                    HStack {
                        Text("Penting!")
                            .foregroundColor(Color.mainLight)
                            .padding(.horizontal)
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    .padding(.leading,3)
                    
                    Text("Harap aktifkan semua kategori dalam dialog yang akan muncul. Tanpa akses penuh, Zora tidak akan dapat memberikan analisis dan wawasan yang lengkap.")
                        .padding(.horizontal)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: 370, maxHeight: 160)
                .background(Color.mainLight.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                    .padding(.leading, 10)
                    .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    manager.requestAuthorization { success, returnedNavigationStates in
                        navigationStates = returnedNavigationStates
                        showAlert = navigationStates["showAlert"] ?? false
                        
                        if success && !showAlert {
                            navigateToNameOnBoarding = true
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
                
                NavigationLink(destination: NameOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding, navigationStates: navigationStates), isActive: $navigateToNameOnBoarding) { EmptyView() }
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
                        navigationStates["showAlert"] = false
                        navigateToNameOnBoarding = true
                    }),
                    secondaryButton: .cancel(Text("Skip"), action: {
                        navigationStates["showAlert"] = false
                        navigateToNameOnBoarding = true
                    })
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct HealthOnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        HealthOnBoardingView(hasCompletedOnboarding: .constant(false))
            .environmentObject(HealthManager())
    }
}


