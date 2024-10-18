//
//  ActivityOnBoardingView.swift
//  Macro
//
//  Created by Nicholas Christian Irawan on 18/10/24.
//

import SwiftUI

struct ActivityOnBoardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        NavigationView{
        VStack{
            Text("Seberapa berat aktivitasmu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.systemWhite)
                .bold()
            
            Button(action: {
                UserDefaults.standard.set(1.2, forKey: "activity")
                hasCompletedOnboarding = true
            }) {
                ZStack{
                    Rectangle()
                        .foregroundColor(.mainLight)
                        .frame(width: 353, height:100)
                        .background(.white)
                        .cornerRadius(12)
                    VStack {
                        Text("Tidak Terlalu Aktif")
                            .bold()
                            .font(.title3)
                        Text("Sebagian besar waktu duduk")
                            .font(.subheadline)
                        Text("(contoh: pekerja kantoran, customer service)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                }
                .padding(.top, 140)
            }

            
            Button(action: {
                UserDefaults.standard.set(1.375, forKey: "activity")
                hasCompletedOnboarding = true
            }) {
                ZStack{
                    Rectangle()
                        .foregroundColor(.mainLight)
                        .frame(width: 353, height:100)
                        .background(.white)
                        .cornerRadius(12)
                    VStack {
                        Text("Sedikit Aktif")
                            .bold()
                            .font(.title3)
                        Text("Sebagian waktu berdiri")
                            .font(.subheadline)
                        Text("(contoh: guru, SPG)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                UserDefaults.standard.set(1.55, forKey: "activity")
                hasCompletedOnboarding = true
            }) {
                ZStack{
                    Rectangle()
                        .foregroundColor(.mainLight)
                        .frame(width: 353, height:100)
                        .background(.white)
                        .cornerRadius(12)
                    VStack {
                        Text("Aktif")
                            .bold()
                            .font(.title3)
                        Text("Sebagian waktu melakukan aktivitas fisik")
                            .font(.subheadline)
                        Text("(contoh: pramusaji, pemandu wisata, kurir paket)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                UserDefaults.standard.set(1.725, forKey: "activity")
                hasCompletedOnboarding = true
            }) {
                ZStack{
                    Rectangle()
                        .foregroundColor(.mainLight)
                        .frame(width: 353, height:100)
                        .background(.white)
                        .cornerRadius(12)
                    VStack {
                        Text("Sangat Aktif")
                            .bold()
                            .font(.title3)
                        Text("Sebagian besar waktu melakukan aktivitas berat")
                            .font(.subheadline)
                        Text("(contoh: penari, tukang)")
                            .font(.subheadline)
                    }
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
//    ActivityOnBoardingView()
//}
