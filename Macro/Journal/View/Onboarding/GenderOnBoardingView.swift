//
//  GenderOnBoardingView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 16/10/24.
//

import SwiftUI

struct GenderOnBoardingView: View {
    var body: some View {
        VStack{
            Text("Apa Jenis Kelaminmu?")
                .padding(.top,80)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.systemWhite)
                .bold()
            
            ZStack{
                Rectangle()
                    .foregroundColor(.mainLight)
                    .frame(width: 353, height:60)
                    .background(.white)
                    .cornerRadius(12)
                Text("♀ Perempuan")
                    .foregroundColor(.white)
                
            }
            .padding()
            .padding(.top, 140)
            
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
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
        .background(Color.main)
    }
}

#Preview {
    GenderOnBoardingView()
}
