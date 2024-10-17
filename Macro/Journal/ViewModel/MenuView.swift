//
//  MenuView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI

struct MenuView: View {
    var image: UIImage?
    
    var body: some View {
        VStack {
            if let image = image {
                
                VStack{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360, height: 300)
                        .cornerRadius(12)
                    
                    HStack {
                        Text("Nama Makanan")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .frame(width: 360)
                    
                    
                    VStack{
                        HStack {
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.trailing, 10)
                                
                                Text("Protein")
                                    .padding()
                                    .fontWeight(.medium)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                
                                Text("Fat")
                                    .padding()
                                    .fontWeight(.medium)
                            }
                        }
                        
                        HStack {
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.trailing, 10)
                                
                                Text("Diaries")
                                    .padding()
                                    .fontWeight(.medium)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 170, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                
                                Text("Glycemic")
                                    .padding()
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                }
            } else {
                Text("No Image Selected")
                    .font(.title)
            }
            
            
            
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MenuView()
}
