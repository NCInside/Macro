//
//  JournalView.swift
//  Macro
//
//  Created by Vebrillia Santoso on 14/10/24.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var context
    @StateObject var viewModel = JournalViewModel()
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var isMenuSheetPresented = false
    @State var navigateToMenuPage = false
    @State var isAddSleepViewPresented = false
    @State var isSettingsViewPresented = false
    @State var navigateToHistoryView = false
    @State var classificationTitle: String = ""
    @State var classificationProb: Double = 0.0
    @State var protein: Double = 0.0
    @State var fat: Double = 0.0
    @State var dairy: Bool = false
    @State private var showToast = false
    @State private var toastMessage: String = ""
    @State var glycemicIndex: glycemicIndex = .low
    @Query var journals: [Journal]
    @State private var showDatePicker = false
    @State private var savedDate: Date? = nil
    @State private var selectedDate: Date = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }
    
    private var todayJournal: Journal? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        return journals.first { journal in
            calendar.isDate(journal.timestamp, inSameDayAs: todayStart)
        }
    }
    
    var body: some View {
        ZStack{
            NavigationStack {
                ScrollView {
                    VStack {
                        HStack {
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                Image(systemName: "calendar")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.trailing, -4)
                            
                            Text("Hari ini, \(dateFormatter.string(from: selectedDate))")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button(action: {
                                
                            }) {
                                Image(systemName: "bell")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.trailing, 2)
                            
                            Button(action: {
                                isSettingsViewPresented = true
                            }) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                            }
                            .sheet(isPresented: $isSettingsViewPresented) {
                                SettingsView()
                            }
                            
                        }
                        .padding()
                        
                        if showDatePicker {
                            DatePickerView(showDatePicker: $showDatePicker, savedDate: $savedDate, selectedDate: $selectedDate)
                                .animation(.linear)
                                .transition(.opacity)
                        }
                        
                        HStack(alignment: .bottom){
                            Text("Tidur")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            
                            Button(action: {
                                isAddSleepViewPresented = true
                            }) {
                                Text("Edit")
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 4)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $isAddSleepViewPresented) {
                            AddSleepView()
                        }
                        
                        ZStack {
                            Image("HomeCard")
                                .resizable()
                                .scaledToFill()
                                .padding(.horizontal, 10)
                            
                            VStack(alignment: .leading){
                                HStack(alignment: .bottom,spacing: 0) {
                                    Text(viewModel.getSleep(journals: journals).hour)
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .bold()
                                    
                                    Text("jam ")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    
                                    Text(viewModel.getSleep(journals: journals).minute)
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .bold()
                                    
                                    Text("menit")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 50)
                                .padding(.bottom, 2)
                                
                                HStack{
                                    Text(viewModel.sleepClassificationMessage(journals: journals))
                                        .foregroundColor(.white)
                                }
                                .padding(.leading, 50)
                                .padding(.bottom, 90)
                            }
                        }
                        .padding(.bottom, -10)
                        
                        HStack(alignment: .bottom) {
                            Text("Detail Makanan")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                            Spacer()
                            
                            Button(action: {
                                viewModel.isDietViewPresented = true
                            }) {
                                Text("Tambah")
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.top, 10)
                            .padding()
                            .padding(.trailing, 4)
                            
                        }
                        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                            ImagePickerViewModel(
                                selectedImage: $selectedImage,
                                isPickerShowing: $isPickerShowing,
                                sourceType: viewModel.sourceType,
                                onImagePicked: {
                                    let image = selectedImage
                                }
                            )
                        }
                        
                        // Sheet to display the MenuView after classification
                        .sheet(isPresented: $isMenuSheetPresented, onDismiss: {
                        }) {
                            MenuView(
                                image: selectedImage,
                                title: classificationTitle,
                                prob: classificationProb,
                                protein: protein,
                                fat: fat,
                                dairy: dairy,
                                glycemicIndex: glycemicIndex.rawValue
                            )
                        }
                        
                        .sheet(isPresented: $viewModel.isDietViewPresented, content: SearchView.init)
                        // Navigation to MenuView with the classified image, title, and probability
                        NavigationLink(
                            destination: MenuView(
                                image: selectedImage,
                                title: classificationTitle,
                                prob: classificationProb,
                                protein: protein,
                                fat: fat,
                                dairy: dairy,
                                glycemicIndex: glycemicIndex.rawValue
                            ),
                            isActive: $navigateToMenuPage
                        ) {
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
                                            .fontWeight(.semibold)
                                            .foregroundColor(.systemGray3)
                                        
                                        Spacer()
                                    }
                                    .background(
                                        Image("drumstick")
                                            .padding(.bottom, -42),
                                        alignment: .bottomTrailing
                                    )
                                    
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                                        Text(String(format: "%.2f"))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.leading)
                                            .padding(.vertical)
                                        
                                        Text("porsi")
                                            .font(.callout)
                                            .foregroundColor(.systemGray3)
                                        
                                        Spacer()
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 2)
                                
                                VStack(alignment: .leading, spacing: -24) {
                                    HStack {
                                        Text("Lemak Jenuh")
                                            .padding()
                                            .fontWeight(.semibold)
                                            .foregroundColor(.systemGray3)
                                        Spacer()
                                    }
                                    .background(
                                        Image("Burger")
                                        
                                            .padding(.bottom, -42),
                                        alignment: .bottomTrailing)
                                    
                                    HStack {
                                        Text(String(format: "%.2f", viewModel.calcFat(journals: journals)))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.leading)
                                            .padding(.vertical)
                                        
                                        Text("gr/17gr")
                                            .font(.callout)
                                            .foregroundColor(.systemGray3)
                                            .padding(.leading, -8)
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                            }
                            
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: -24) {
                                    HStack {
                                        Text("Produk Susu")
                                            .padding()
                                            .fontWeight(.semibold)
                                            .foregroundColor(.systemGray3)
                                        Spacer()
                                    }
                                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                                        Text(String(viewModel.calcDairy(journals: journals)))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.leading)
                                            .padding(.vertical)
                                        
                                        Text("kali/1 porsi")
                                            .font(.callout)
                                            .foregroundColor(.systemGray3)
                                        Spacer()
                                    }
                                    .background(
                                        Image("Milk")
                                        
                                            .padding(.bottom, -20),
                                        alignment: .bottomTrailing
                                    )
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                                
                                VStack(alignment: .leading, spacing: -24) {
                                    HStack {
                                        Text("Indeks Glikemik")
                                            .padding()
                                            .fontWeight(.semibold)
                                            .foregroundColor(.systemGray3)
                                    }
                                    .background(
                                        Image("Donut")
                                            .padding(.trailing, -40)
                                        
                                            .padding(.bottom, -60),
                                        alignment: .bottomTrailing
                                    )
                                    
                                    HStack {
                                        Text(String(viewModel.calcGI(journals: journals)))
                                            .padding()
                                            .fontWeight(.bold)
                                            .font(.title)
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, -60)
                        
                        HStack(alignment: .bottom) {
                            Text("Riwayat Harian")
                                .font(.title2)
                                .fontWeight(.bold)
//                                .padding()
                            
                            Spacer()
                            
                            NavigationLink(destination: HistoryView(), isActive: $navigateToHistoryView) {Button(action: {
                                navigateToHistoryView = true
                            }) {
                                Text("Lihat Semua")
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 4)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                        
                        VStack (spacing: 0){
                            HStack {
                                HStack{
                                    Text("Data Makanan")
                                    Spacer()
                                    Text("Jam")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                
                               
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            Divider()
                                .padding(.leading)
                        }
                        .background(Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 2)
                        
                
                        
                    }
                    .background(Color.white).edgesIgnoringSafeArea(.all)
                }
                .onAppear {
                    viewModel.fetchSleepData(context: context, journals: journals)
                    
                    if let saved = savedDate {
                        selectedDate = saved
                    }
                }
                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastMessage)
                            .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.5), value: showToast)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
