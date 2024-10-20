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
                            .frame(width: 353, height:80)
                            .background(.white)
                            .cornerRadius(12)
                        
                        VStack {
                            Text("Tidak Terlalu Aktif")
                                .foregroundColor(.white)
                                .bold()
                            
                            Text("""
                                 Sebagian besar waktu duduk
                                 (contoh : pekerja kantoran, customer service)
                                 """)
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        }
                        
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
                            .frame(width: 353, height:80)
                            .background(.white)
                            .cornerRadius(12)
                        
                        VStack {
                            Text("Sedikit Aktif")
                                .foregroundColor(.white)
                                .bold()
                            
                            Text("""
                                 Sebagian besar waktu duduk
                                 (contoh : pekerja kantoran, customer service)
                                 """)
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        }
                    }
                    .padding(.top)
                }
                
                Button(action: {
                    UserDefaults.standard.set(1.55, forKey: "activity")
                    hasCompletedOnboarding = true
                }) {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.mainLight)
                            .frame(width: 353, height:80)
                            .background(.white)
                            .cornerRadius(12)
                        
                        VStack {
                            Text("Aktif")
                                .foregroundColor(.white)
                                .bold()
                            
                            Text("""
                                 Sebagian waktu melakukan aktivitas fisik
                                 (contoh: pramusaji, pemandu wisata, kurir paket)
                                 """)
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        }
                    }
                    .padding(.top)
                }
                
                Button(action: {
                    UserDefaults.standard.set(1.725, forKey: "activity")
                    hasCompletedOnboarding = true
                }) {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.mainLight)
                            .frame(width: 353, height:80)
                            .background(.white)
                            .cornerRadius(12)
                        
                        VStack {
                            Text("Sangat Aktif")
                                .foregroundColor(.white)
                                .bold()
                            
                            Text("""
                                Sebagian besar waktu melakukan aktivitas berat
                                (contoh: penari, tukang)
                                """)
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        }
                    }
                    .padding(.top)
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
