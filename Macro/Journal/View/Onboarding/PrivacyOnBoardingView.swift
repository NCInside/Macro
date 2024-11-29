//
//  PrivacyOnBoardingView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 15/10/24.
//

import SwiftUI

struct PrivacyOnBoardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State var navigateToHealthOnBoarding = false
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Spacer()
                
                Image("Logo")
                    .padding(.horizontal)
                
                Text("Kami Menghargai Privasi Anda")
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                
                Text("Zora tidak mengumpulkan informasi pribadi apa pun. Semua data Anda disimpan dengan aman di perangkat Anda dan di penyimpanan iCloud pribadi Anda. Dengan melanjutkan, Anda menyetujui kebijakan privasi kami.")
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Spacer()
                NavigationLink(destination: HealthOnBoardingView(hasCompletedOnboarding: $hasCompletedOnboarding), isActive: $navigateToHealthOnBoarding){
                    Button(action: {
                        navigateToHealthOnBoarding = true
                        
                    }) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.accentColor)
                                .frame(width: .infinity, height: 50)
                                .background(.white)
                                .cornerRadius(12)
                            Text("Lanjutkan")
                                .foregroundColor(.white)
                            
                        }
                        .padding()
                        
                    }
                }
                
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .background(Color.main)
            
        }
        
    }
       
}

//#Preview {
//    PrivacyOnBoardingView()
//}
