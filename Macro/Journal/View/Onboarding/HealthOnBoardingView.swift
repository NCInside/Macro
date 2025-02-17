//
//  HealthOnBoardingView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI

struct HealthOnBoardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var manager: HealthManager
    @State private var navigateToAgeOnBoarding = false
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
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
                    manager.requestAuthorization { success in
//                        if success {
//                            hasCompletedOnboarding = true
//                        } else {
//                            navigateToAgeOnBoarding = true
//                        }
                        navigateToAgeOnBoarding = true
                    }
                }) {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: 353, height: 50)
                            .background(.white)
                            .cornerRadius(12)
                        Text("Izinkan")
                            .foregroundColor(.white)
                        
                        
                    }
                    .padding()
                    
                    
                }

                NavigationLink(destination: AgeOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigateToAgeOnBoarding) {
                    EmptyView()
                }
                
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .background(Color.main)
        }
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    HealthOnBoardingView()
//        .environmentObject(HealthManager())
//}
