//
//  JournalView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI

struct JournalView: View {
    @ObservedObject var viewModel = JournalViewModel()
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var navigateToMenuPage = false
    
    var body: some View {
        NavigationView{
            VStack {
            HStack{
                Text("Hi!")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                
                Spacer()
            }
            .padding()
            
            VStack{
                HStack{
                    Text(viewModel.getMonthInIndonesian())
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .padding(.top, 12)
                
                HStack {
                    ForEach(viewModel.days, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                HStack {
                    ForEach(viewModel.daysInCurrentWeek(), id: \.self) { date in
                        VStack {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.body)
                                .frame(width: 18, height: 16)
                                .multilineTextAlignment(.center)
                                .padding(12)
                                .background(viewModel.isSelected(date: date) ? Color.gray.opacity(0.3) : Color.clear)
                                .clipShape(Circle())
                        }
                        .onTapGesture {
                            viewModel.selectDate(date: date)
                        }
                    }
                }
                .padding(.top, 6)
            }
            .frame(width: 360, height: 170,  alignment: .topLeading)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            
            HStack{
                Text("Durasi Tidur")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Edit")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .padding(.trailing, 4)
            }
            .padding()
            .padding(.top, 10)
            
            ZStack(alignment: .bottomLeading){
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 360, height: 120)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.sleepDuration)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .padding(.leading, 16)
                        .padding()
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        
                    }) {
                        Text("Add Data")
                            .foregroundColor(.blue)
                            .padding(.leading, 32)
                            .padding(.top,4)
                            .padding(.bottom)
                    }
                }
            }.padding(.top, -10)
            
            HStack{
                Text("Diet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                
                
                Button(action: {
                    viewModel.presentActionSheet()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .padding()
                .padding(.trailing, 4)
                .actionSheet(isPresented: $viewModel.isImagePickerPresented) {
                    ActionSheet(title: Text("Pilih gambar melalui"), buttons: [
                        .default(Text("Ambil Gambar")) {
                            isPickerShowing = true
                            viewModel.sourceType = .camera
                        },
                        .default(Text("Pilih dari Galeri")) {
                            isPickerShowing = true
                            viewModel.sourceType = .photoLibrary
                        },
                        .default(Text("Cari Menu Makanan")) {
                            viewModel.isDietViewPresented = true
                        },
                        .cancel()
                    ])
                }
            }
            .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                ImagePickerViewModel(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing, sourceType: viewModel.sourceType, onImagePicked: {
                    navigateToMenuPage = true
                })
            }
            .sheet(isPresented: $viewModel.isDietViewPresented) {
                DietView()
            }
            NavigationLink(destination: MenuView(image: selectedImage), isActive: $navigateToMenuPage) {
                EmptyView()
            }
            
            
            .padding()
            .padding(.top, 10)
            
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
            .padding(.top, -60)
          
                HStack{
                    Text("More")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                
                Button(action: {
                    
                }) {
                    Text("Tampilkan Semua Riwayat Data")
                        .foregroundColor(.blue)
                }
                .onAppear {
                            viewModel.fetchSleepData() 
                        }
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
            
    }
        
        
    }
}



#Preview {
    JournalView()
}
