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
    @State var navigateToReminderView = false
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
    @State private var isReminderSheetPresented = false
    @State private var showDatePicker = false
    @State private var savedDate: Date? = nil
    
    @State var isInfoSheetPresented = false
    @State private var isDataLoaded = false
    
    private var GIs: [glycemicIndex: Int]? {
        viewModel.calcGIDetail(journals: journals)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }
    
    private var hourFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter
    }
    
    var body: some View {
        VStack{
            NavigationStack {
                ScrollView {
                    if isDataLoaded {
                        VStack {
                            HStack{
                                Text("Jurnal Harian")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    isReminderSheetPresented = true
                                }) {
                                    Image(systemName: "bell")
                                        .imageScale(.large)
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.trailing, 2)
                                
                                Button(action: {
                                    isSettingsViewPresented = true
                                }) {
                                    Image(systemName: "person")
                                        .imageScale(.large)
                                        .foregroundColor(.accentColor)
                                }
                                .sheet(isPresented: $isSettingsViewPresented) {
                                    SettingsView( journalViewModel: viewModel,
                                                  journals: journals)
                                }
                                
                            }
                            .padding(.top, 36)
                            .padding(.horizontal)
                            
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                
                                HStack {
                                    Button(action: {
                                        viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                                        viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                                            }) {
                                                Image(systemName: "chevron.left")
                                                    .foregroundColor(.accentColor)
                                            }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showDatePicker.toggle()
                                    }) {
                                        Text(" \(dateFormatter.string(from: viewModel.selectedDate))")
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                                        viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                                            }) {
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.accentColor)
                                            }
                                            .disabled(Calendar.current.isDateInToday(viewModel.selectedDate))
                                                .opacity(Calendar.current.isDateInToday(viewModel.selectedDate) ? 0.5 : 1.0)
                                }
                                .padding(.horizontal)
                                
                            }
                            .padding(.top, -8)
//                            .blur(radius: showDatePicker ? 5 : 0)
                            
                            
                            if showDatePicker {
                                DatePickerView(showDatePicker: $showDatePicker, savedDate: $savedDate, selectedDate: $viewModel.selectedDate)
                                    .animation(.linear)
                                    .transition(.opacity)
                                    .onChange(of: viewModel.selectedDate) {
                                        viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                                    }
                            }
                            
                            HStack(alignment: .bottom){
                                Text("Waktu Tidur")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                Button(action: {
                                    isAddSleepViewPresented = true
                                }) {
                                    Text("Edit")
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.top, 20)
                                .padding(.trailing, 4)
                                
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $isAddSleepViewPresented) {
                                AddSleepView(date: viewModel.selectedDate)
                            }
                            
                            
                            
                            
                                VStack(alignment: .leading){
                                    HStack(alignment: .bottom,spacing: 0) {
                                        Text(viewModel.getSleep(journals: journals).hour)
                                            .font(.title)
                                            .foregroundColor(.black)
                                            .bold()
                                        
                                        Text("jam ")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .fontWeight(.semibold)
                                        
                                        Text(viewModel.getSleep(journals: journals).minute)
                                            .font(.title)
                                            .foregroundColor(.black)
                                            .bold()
                                        
                                        Text("menit")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 14)
                                    .padding(.bottom, 2)
                                    
                                    HStack{
                                        Text(viewModel.sleepClassificationMessage(journals: journals))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.leading, 16)
                                
                            }
                                .padding(.vertical, 8)
                                .frame(maxWidth: 365, maxHeight: 180)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 2, y: 2)
                            
                            
                            HStack(alignment: .bottom){
                                Text("Detail Makanan")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                Button(action: {
                                    isInfoSheetPresented = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.top, 20)
                                .padding(.trailing, 4)
                                
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $isInfoSheetPresented) {
                                InfoView()
                            }
                            
                            Button(action: {
                                viewModel.isDietViewPresented = true
                            }) {
                                Text("+ Tambah Makanan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: 48)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            }
                            .padding()
                            .padding(.top, -20)
                            .padding(.bottom, 2)
                            
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: -24) {
                                        HStack {
                                            Text("Makanan Berlemak")
                                                .padding(.leading, 10)
                                                .padding(.vertical)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.systemGray3)
                                            
                                            Spacer()
                                        }
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                                            Text(String(viewModel.calcFat(journals: journals)))
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .padding(.leading, 10)
                                                .padding(.vertical)
                                            
                                            Text("porsi")
                                                .font(.callout)
                                            
                                            Spacer()
                                        }
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 2, y: 2)
                                    
                                    VStack(alignment: .leading, spacing: -24) {
                                        HStack {
                                            Text("Produk Susu")
                                                .padding(.vertical)
                                                .padding(.leading, 10)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.systemGray3)
                                            Spacer()
                                        }
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                                            Text(String(viewModel.calcDairy(journals: journals)))
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .padding(.leading, 10)
                                                .padding(.vertical)
                                            
                                            
                                            Text("porsi")
                                                .font(.callout)
                                            
                                            Spacer()
                                        }                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                                }
                                
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: -24) {
                                        HStack {
                                            Text("Indeks Glikemik")
                                                .padding(.vertical)
                                                .padding(.leading, 10)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.systemGray3)
                                            
                                            Spacer()
                                        }
                                        .padding(.bottom, 20)
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text("Rendah: ")
                                            if let low = GIs?[.low] {
                                                Text("\(String(low))")
                                                    .bold()
                                                    .padding(.leading, -10)
                                            } else {
                                                Text("0")
                                                    .bold()
                                                    .padding(.leading, -10)
                                            }
                                                
                                            
                                            Spacer()
                                            Divider()
                                            Spacer()
                                            
                                            Text("Sedang: ")
                                            if let medium = GIs?[.medium] {
                                                Text("\(String(medium))")
                                                    .bold()
                                                    .padding(.leading, -10)
                                            } else {
                                                Text("0")
                                                    .bold()
                                                    .padding(.leading, -10)
                                            }
                                            
                                            Spacer()
                                            Divider()
                                            Spacer()
                                            
                                            Text("Tinggi: ")
                                            if let high = GIs?[.high] {
                                                Text("\(String(high))")
                                                    .bold()
                                                    .padding(.leading, -10)
                                            } else {
                                                Text("0")
                                                    .bold()
                                                    .padding(.leading, -10)
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                    }
                                    .padding(.bottom, 20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, -12)
                            .sheet(isPresented: $viewModel.isDietViewPresented) {
                                SearchView(isDetailViewPresented: $viewModel.isDietViewPresented, date: viewModel.selectedDate)
                            }
                            
                            HStack(alignment: .bottom) {
                                Text("Riwayat Harian")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                //                                .padding()
                                
                                Spacer()
                                
                                NavigationLink(destination: HistoryView(), isActive: $navigateToHistoryView) {Button(action: {
                                    navigateToHistoryView = true
                                }) {
                                    Text("Lihat Semua")
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.top,6)
                                .padding(.trailing, 4)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 16)
                            
                            VStack (spacing: 0){
                                if let foods = viewModel.hasEntriesFromDate(entries: journals, date: viewModel.selectedDate)?.foods.sorted(by: { $0.timestamp < $1.timestamp }).reversed() {
                                    ForEach(foods) { food in
                                        HStack {
                                            HStack{
                                                Text(food.name)
                                                Spacer()
                                                Text("\(hourFormatter.string(from: food.timestamp))")
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
                                }
                            }
                            .background(Color(UIColor.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 2)
                            
                        }
                        .padding(.top, 36)
                        .background(Color.background).edgesIgnoringSafeArea(.all)
                    }
                }
                .padding(.bottom, 100)
                .background(Color.background).edgesIgnoringSafeArea(.all)
                
            }
            .onAppear {
                viewModel.fetchSleepData(context: context, journals: journals, date: viewModel.selectedDate)
                
                if !isDataLoaded {
                    isDataLoaded.toggle()
                }
                
                // Get the value for "sleepConnected" from UserDefaults
                let sleepConnected = UserDefaults.standard.bool(forKey: "sleepConnected")

                // Check if sleepConnected is false, and if so, schedule the notification
                if !sleepConnected {
                    let content = UNMutableNotificationContent()
                    content.title = "Zora - Sleep"
                    content.subtitle = "Jangan lupa untuk memasukkan data tidur anda!"
                    content.sound = UNNotificationSound.default
                    
                    var dateComponents = DateComponents()
                    dateComponents.hour = 9
                    dateComponents.minute = 30
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let notificationIdentifier = "uniqueNotificationId"
                    
                    // Cancel existing notification with the same identifier
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                    
                    // Create the notification request
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                    
                    // Add the notification request to the notification center
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error adding notification: \(error.localizedDescription)")
                        }
                    }
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
        .sheet(isPresented: $isReminderSheetPresented) {
            ReminderView(viewModel: ReminderViewModel())
                .environment(\.modelContext, context)
        }
    }
    
}

#Preview {
    ContentView()
}
