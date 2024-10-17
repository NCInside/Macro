//
//  GenderOnBoardingView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 16/10/24.
//

import SwiftUI

struct GenderOnBoardingView: View {
    @State private var navigateToJournalView = false
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        NavigationView{
        VStack{
            Text("Apa Jenis Kelaminmu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.systemWhite)
                .bold()
            
            Button(action: {
                UserDefaults.standard.set("Perempuan", forKey: "gender")
                hasCompletedOnboarding = true
            }) {
                ZStack{
                    Rectangle()
                        .foregroundColor(.mainLight)
                        .frame(width: 353, height:60)
                        .background(.white)
                        .cornerRadius(12)
                    Text("♀ Perempuan")
                        .foregroundColor(.white)
                    
                }) {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: 353, height:60)
                            .background(.white)
                            .cornerRadius(12)
                        Text("♀ Perempuan")
                            .foregroundColor(.white)
                        
                    }
                    .padding()
                    .padding(.top, 140)
                }
                .padding()
                .padding(.top, 140)
            }

            
            Button(action: {
                UserDefaults.standard.set("Laki-Laki", forKey: "gender")
                hasCompletedOnboarding = true
            }) {
                ZStack{
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
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
        .background(Color.main)
    }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    GenderOnBoardingView()
//}
