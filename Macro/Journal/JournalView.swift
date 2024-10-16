//
//  JournalView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @ObservedObject var viewModel = JournalViewModel()
    @State private var userAge: Int? = nil
    let manager = HealthManager()
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var navigateToMenuPage = false
    @State var isAddSleepViewPresented = false
    @State var navigateToHistoryView = false
    @Query var journals: [Journal]
    
    private var todayJournal: Journal? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        return journals.first { journal in
            calendar.isDate(journal.timestamp, inSameDayAs: todayStart)
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack{
                    Text("Ringkasan")
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
                                .foregroundColor(.systemMint)
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
                        isAddSleepViewPresented = true
                    }) {
                        Text("Tambah")
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
                            Text("Edit Data")
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
                                .default(Text("🖼 Pilih Foto dari Album")){
                                isPickerShowing = true
                                viewModel.sourceType = .photoLibrary
                            },
                            .default(Text("📷 Ambil Gambar")) {
                                isPickerShowing = true
                                viewModel.sourceType = .camera
                            },
                            .default(Text("🔍 Cari Menu Makanan")) {
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
                
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: -24) {
                            HStack {
                                Text("Protein")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            HStack {
                                Text(String(format: "%.2f", calcProtein())+" gr")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: -24) {
                            HStack {
                                Text("Fat")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            HStack {
                                Text(String(format: "%.2f", calcFat())+" gr")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    }
                    
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: -24) {
                            HStack {
                                Text("Diaries")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            HStack {
                                Text(String(calcDairy())+" product(s)")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: -24) {
                            HStack {
                                Text("Glycemic")
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            HStack {
                                Text(String(calcGI()))
                                    .padding()
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.top, -60)
                
                HStack{
                    Text("More")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                NavigationLink(destination: HistoryView(), isActive: $navigateToHistoryView) {
                Button(action: {
                    navigateToHistoryView = true
                }) {
                    HStack {
                        Text("Tampilkan Semua Data")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.top, -12)
                .onAppear {
                    viewModel.fetchSleepData()
                }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.background)
            .sheet(isPresented: $isAddSleepViewPresented) { // Memunculkan AddSleepView sebagai modal sheet
                AddSleepView()
                
            }}
    }
    
    private func calcProtein() -> Double {
        var protein: Double = 0
        if let todayJournal {
            for food in todayJournal.foods {
                protein += food.protein
            }
        }
        return protein
    }
    
    private func calcFat() -> Double {
        var fat: Double = 0
        if let todayJournal {
            for food in todayJournal.foods {
                fat += food.fat
            }
        }
        return fat
    }
    
    private func calcDairy() -> Int {
        var dairy = 0
        if let todayJournal {
            for food in todayJournal.foods {
                dairy += food.dairy ? 1 : 0
            }
        }
        return dairy
    }
    
    private func calcGI() -> Int {
        var gi = 0
        if let todayJournal {
            for food in todayJournal.foods {
                switch food.glycemicIndex {
                case .low:
                    continue
                case .medium:
                    gi += 1
                case .high:
                    gi += 2
                }
            }
        }
        return gi
    }
        
}



#Preview {
    JournalView()
}
